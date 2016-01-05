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
  class Imposition

    # Imposition template
    TEMPLATE = <<-EOT.gsub(/^\s+/, '')
      \\documentclass[@@papersize@@,10pt]{article}

      \\usepackage{pgfpages}
      \\usepackage{pdfpages}

      \\pgfpagesuselayout{@@nup@@ on 1}[@@papersize@@@@extra@@]

      \\begin{document}
        \\includepdf[pages={@@pages@@}]{@@document@@}
      \\end{document}
      EOT

    attr_accessor :imposed_file, :original_file, :pages, :rounded_pages, :blank_pages, :template,
      :papersize, :nup, :extra_options

    def initialize(file, papersize = 'a4paper', nup = 4, extra_options = '')
      return unless /\.pdf\Z/ =~ file
      return unless pdf = PDF::Info.new(file)

      @original_file = File.realpath(file)
      @imposed_file  = file.gsub(/\.pdf\Z/, '-imposed.pdf')
      @papersize     = papersize
      @pages         = pdf.metadata[:page_count]
      @nup           = nup
      @extra_options = extra_options
      # Total pages must be modulo 4
      @rounded_pages = round_to_nearest(@pages, 4)
      @blank_pages   = @rounded_pages - @pages

      @template = TEMPLATE
        .gsub('@@nup@@',       @nup.to_s)
        .gsub('@@papersize@@', @papersize)
        .gsub('@@extra@@',     @extra_options)
        .gsub('@@document@@',  @original_file)
        .gsub('@@pages@@',     to_nup * ',')
    end

    def round_to_nearest(int, near)
      (int + (near - 1)) / near * near
    end

    def to_nup
      # 14 pages example:
      # [ {}, 1, 2, {}, 14, 3, 4, 13, 12, 5, 6, 11, 10, 7, 8, 9 ]
      #
      # * Add {} to missing pages
      #   [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, {}, {}]
      # * Take first half [ 1, 2, 3, 4, 5, 6, 7, 8 ]
      # * Reverse second half [ {}, {}, 14, 13, 12, 11, 10, 9 ]
      # * Intercalate the first half into the second half by two
      #   elements
      #   [ {}, 1, 2, {}, 14, 3, 4, 13, 12, 5, 6, 11, 10, 7, 8, 9 ]
      #
      # An array of numbered pages padded with blank pages ('{}')
      #
      # [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ] + [ '{}', '{}' ]
      padded = @pages.times.map{|i|i+1} + Array.new(@blank_pages, '{}')
      # Split in halves
      # [ [ 1, 2, 3, 4, 5, 6, 7, 8 ],
      #   [ 9, 10, 11, 12, 13, 14, '{}', '{}' ] ]
      halved = padded.each_slice(@rounded_pages / 2).to_a
      # Add a nil as last page.  When we reverse it and intercalate by
      # two pages, we'll have [nil, last_page] instead of
      # [last_page,second_to_last_page]
      #
      # [ [ 1, 2, 3, 4, 5, 6, 7, 8 ],
      #   [ 9, 10, 11, 12, 13, 14, '{}', '{}', nil ] ]
      halved.last << nil
      # Reverse the second half and intercalate by two pages into the
      # first one.  Then remove nil elements and flatten the array.
      #
      # [ [ 1, 2, 3, 4, 5, 6, 7, 8 ],
      #   [ nil, '{}', '{}', 14, 13, 12, 11, 10 ] ]
      #
      # [ {}, 1, 2, {}, 14, 3, 4, 13, 12, 5, 6, 11, 10, 7, 8, 9 ]
      order = halved.last.reverse.each_slice(2).zip(halved.first.each_slice(2).to_a).flatten.compact

      # Create the matrix of pages (N-Up)
      #
      # ["{}", 1, "{}", 1, 2, "{}", 2, "{}", 14, 3, 14, 3, 4, 13, 4, 13, 12, 5, 12, 5, 6, 11, 6, 11, 10, 7, 10, 7, 8, 9, 8, 9]
      order.each_slice(2).map{ |i| ((@nup/2)-1).times { i = i+i }; i }.flatten
    end

    def write
      # Create the imposed file
      pdflatex = RTeX::Document.new(@template)
      pdflatex.to_pdf do |pdf_file|
        FileUtils.cp pdf_file, @imposed_file
      end
    end
  end
end
