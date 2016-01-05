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

# Namespacing and metaprogramming FTW
module JekyllPandocMultipleFormats
  # Determines the correct module where it lives the converter
  def self.namespace
    Jekyll::VERSION >= '1.0.0' ? Jekyll::Converters : Jekyll
  end

  # Determines the correct class name. Jekyll has the converters class kinda
  # hardcoded
  def self.class_name
    Jekyll::VERSION >= '1.0.0' ? 'Markdown' : 'MarkdownConverter'
  end

  def self.build
    namespace::const_get(class_name).send :include, ConverterMethods
  end

  # When included in the correspondant markdown class this module redefines the
  # three needed Converter instance methods
  module ConverterMethods
    def self.included(base)
      base.class_eval do
        # Just return html5
        def convert(content)
          flags  = "#{@config['pandoc']['flags']} #{@config['pandoc']['site_flags']}"

          output = ''
          Dir::chdir(@config['source']) do
            Open3::popen3("pandoc -t html5 #{flags}") do |stdin, stdout, stderr|
              stdin.puts content
              stdin.close

              output = stdout.read.strip
              STDERR.print stderr.read

            end
          end

          output
        end

        def matches(ext)
          rgx = '(' + @config['markdown_ext'].gsub(',','|') +')'
          ext =~ Regexp.new(rgx, Regexp::IGNORECASE)
        end

        def output_ext(ext)
          ".html"
        end
      end
    end
  end
end

# Conjures the metamagic
JekyllPandocMultipleFormats.build
