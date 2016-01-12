# Copyright (c) 2012-2015 Nicolás Reynolds <fauno@endefensadelsl.org>
#               2012-2013 Mauricio Pasquier Juan <mpj@endefensadelsl.org>
#               2013      Brian Candler <b.candler@pobox.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'pdf/info'
require 'rtex'

module JekyllPandocMultipleFormats
  class Binder
    # Binder template
    TEMPLATE = <<-EOT.gsub(/^\s+/, '')
      \\documentclass[@@sheetsize@@,10pt]{article}

      \\usepackage{pgfpages}
      \\usepackage{pdfpages}

      \\pgfpagesuselayout{@@nup@@ on 1}[@@sheetsize@@,@@extra_options@@]

      \\begin{document}
        \\includepdf[pages={@@pages@@}]{@@document@@}
      \\end{document}
      EOT

    SHEET_SIZES = {
      a7paper:   2,
      a6paper:   4,
      a5paper:   8,
      a4paper:  16,
      a3paper:  32,
      a2paper:  64,
      a1paper: 128,
      a0paper: 256
    }

    attr_accessor :imposed_file, :original_file, :pages, :rounded_pages, :blank_pages, :template,
      :papersize, :nup, :extra_options

    def initialize(file, papersize = nil, sheetsize = nil, extra_options = nil)
      return unless /\.pdf\Z/ =~ file
      return unless pdf = PDF::Info.new(file)

      @original_file = File.realpath(file)
      @binder_file   = file.gsub(/\.pdf\Z/, '-binder.pdf')
      @papersize     = papersize || 'a5paper'
      @sheetsize     = sheetsize || 'a4paper'
      @pages         = pdf.metadata[:page_count]
      @nup           = SHEET_SIZES[@sheetsize.to_sym] / SHEET_SIZES[@papersize.to_sym]
      @extra_options = extra_options || ''

      # These layouts require a landscape page
      @extra_options << 'landscape' if [2,8,32,128].include? @nup

      @template = TEMPLATE
        .gsub('@@nup@@',           @nup.to_s)
        .gsub('@@sheetsize@@',     @sheetsize)
        .gsub('@@extra_options@@', @extra_options)
        .gsub('@@document@@',      @original_file)
        .gsub('@@pages@@',         to_nup * ',')
    end

    def to_nup
      @pages.times.map{|i|i+1}.map do |page|
        sheet=[]
        @nup.times do
          sheet << page
        end

        sheet
      end.flatten
    end

    def write
      # Create the imposed file
      pdflatex = RTeX::Document.new(@template)
      pdflatex.to_pdf do |pdf_file|
        FileUtils.cp pdf_file, @binder_file
      end
    end
  end
end
