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

    def initialize(file, papersize = nil, sheetsize = nil, signature = nil, extra_options = nil)
      return unless /\.pdf\Z/ =~ file
      return unless pdf = PDF::Info.new(file)

      @original_file = File.realpath(file)
      @imposed_file  = file.gsub(/\.pdf\Z/, '-imposed.pdf')
      @papersize     = papersize || 'a5paper'
      @sheetsize     = sheetsize || 'a4paper'
      @pages         = pdf.metadata[:page_count]
      @nup           = SHEET_SIZES[@sheetsize.to_sym] / SHEET_SIZES[@papersize.to_sym]
      @extra_options = extra_options || ''
      # Total pages must be modulo 4
      @rounded_pages = round_to_nearest(@pages, 4)
      @blank_pages   = @rounded_pages - @pages
      # If we don't use a signature, make a single fold
      @signature     = signature || @rounded_pages

      # These layouts require a landscape page
      @extra_options << 'landscape' if [2,8,32,128].include? @nup

      @template = TEMPLATE
        .gsub('@@nup@@',           @nup.to_s)
        .gsub('@@sheetsize@@',     @sheetsize)
        .gsub('@@extra_options@@', @extra_options)
        .gsub('@@document@@',      @original_file)
        .gsub('@@pages@@',         to_nup * ',')
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

      # If we have a signature, we have to split in groups up to the
      # amount of pages per signature, and then continue with the rest
      #
      # If we have no signature, we assume it's equal to the total
      # amount of pages, so you only have one fold
      signed = padded.each_slice(@signature).to_a
      folds = []
      signed.each do |fold|
        #
        # Split in halves
        # [ [ 1, 2, 3, 4, 5, 6, 7, 8 ],
        #   [ 9, 10, 11, 12, 13, 14, '{}', '{}' ] ]
        halved = fold.each_slice(@signature / 2).to_a
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
        folds << halved.last.reverse.each_slice(2).zip(halved.first.each_slice(2).to_a).flatten.compact
      end

      # Create the matrix of pages (N-Up) per fold
      #
      # ["{}", 1, "{}", 1, 2, "{}", 2, "{}", 14, 3, 14, 3, 4, 13, 4, 13, 12, 5, 12, 5, 6, 11, 6, 11, 10, 7, 10, 7, 8, 9, 8, 9]
      folds.map { |o| o.each_slice(2).map{ |i| a=[]; (@nup/2).times { a = a+i }; a }}.flatten
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
