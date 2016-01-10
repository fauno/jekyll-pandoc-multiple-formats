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

module Jekyll

class PandocGenerator < Generator
  def generate(site)
    config  = site.config['pandoc']

    return if config['skip']

    outputs = config['outputs']
    flags   = config['flags']

    outputs.each_pair do |output, extra_flags|


      # If there isn't a config entry for pandoc's output throw it with the rest
      base_dir = File.join(site.source, config['output']) || site.source

      site.posts.each do |post|

        post_path = File.join(base_dir, output, File.dirname(post.url))

        puts "Creating #{post_path}"
        FileUtils.mkdir_p(post_path)

        filename = post.url.gsub(/\.html$/, ".#{output}")
        # Have a filename!
        filename = "#{post.url.gsub(/\//, '-').gsub(/-$/, '')}.#{output}" if filename =~ /\/$/

        filename_with_path = File.join(base_dir, output, filename)

        # Special cases, stdout is disabled for these
        if ['pdf', 'epub', 'odt', 'docx'].include?(output)
          output_flag = "-o #{filename_with_path}"
        else
          output_flag = "-t #{output} -o #{filename_with_path}"
        end

        # Add cover if epub
        if output == 'epub' and not post.data['cover'].nil?
          output_flag << ' --epub-cover-image='
          output_flag << post.data['cover']
        end

        if output == 'pdf'
          post.data['papersize'] ||= config['papersize']
          post.data['sheetsize'] ||= config['sheetsize']

          output_flag << ' -V papersize='
          output_flag << post.data['papersize']
        end

        # The command
        pandoc = "pandoc #{flags} #{output_flag} #{extra_flags}"

        # Inform what's being done
        puts pandoc

        # Make the markdown header so pandoc receives metadata
        # TODO reject anything that's not an string, integer, array or
        # hash
        content  = "#{post.data.reject{|k| k == 'excerpt'}.to_yaml}\n---\n"
        content << post.content

        # Move to the source dir since everything will be relative to # that
        Dir::chdir(site.config['source']) do
          # Do the stuff
          Open3::popen3(pandoc) do |stdin, stdout, stderr|
            stdin.puts content
            stdin.close
            STDERR.print stderr.read
          end
        end

        # Skip failed files
        next unless File.exist? filename_with_path

        # If output is PDF, we also create the imposed PDF
        if output == 'pdf' and config['imposition']

          imposed_file = JekyllPandocMultipleFormats::Imposition
            .new(filename_with_path, post.data['papersize'], post.data['sheetsize'])

          if imposed_filename = imposed_file.write
            site.static_files << StaticFile.new(site, base_dir, output, imposed_file)
          end
        end

        # Add them to the static files list
        site.static_files << StaticFile.new(site, base_dir, output, filename)
      end
    end
    end
end
end
