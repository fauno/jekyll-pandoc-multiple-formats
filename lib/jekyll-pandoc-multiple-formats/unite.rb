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

module JekyllPandocMultipleFormats
  class Unite < Printer
    TEMPLATE = <<-EOT.gsub(/^\s+/, '')
      \\documentclass{article}
      \\usepackage{pdfpages}

      \\begin{document}
        @@include@@
      \\end{document}
      EOT

    INCLUDE_TEMPLATE = '\\includepdf[fitpaper=true,pages=-]{@@document@@}'

    attr_accessor :files, :template

    def initialize(output_file, files)
      raise ArgumentError.new 'An array of filenames is required' unless files.is_a? Array

      @output_file = output_file
      @files       = files

      render_template
      self
    end

    def <<(file)
      @files << File.realpath(file) if /\.pdf\Z/ =~ file
    end

    def files=(file_array)
      return unless file_array.is_a? Array

      file_array.each do |f|
        self << f
      end
    end

    def render_template
      includes = @files.map do |f|
        INCLUDE_TEMPLATE.gsub(/@@document@@/, f)
      end

      @template = TEMPLATE.gsub('@@include@@', includes.join("\n"))
    end
  end
end
