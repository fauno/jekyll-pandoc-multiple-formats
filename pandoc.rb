require 'open3'

module Jekyll

class PandocGenerator < Generator
  def generate(site)
    outputs = site.config['pandoc']['outputs']
    flags  = site.config['pandoc']['flags']

    outputs.each_pair do |output, extra_flags|

      # Skip conversion if we're skipping, but still cleanup the outputs hash
      next if site.config['pandoc']['skip']

      # If there isn't a config entry for pandoc's output throw it with the rest
      base_dir = site.config['pandoc']['output'] || site.source

      site.posts.each do |post|

        post_path = File.join(base_dir, output, File.dirname(post.url))

        puts "Creating #{post_path}"
        FileUtils.mkdir_p(post_path)

        filename = post.url.gsub(/\.html$/, ".#{output}")

        filename_with_path = File.join(post_path, filename)

        # Special cases, stdout is disabled for these
        if ['pdf', 'epub', 'odt', 'docx'].include?(output)
          output_flag = "-o #{filename_with_path}"
        else
          output_flag = "-t #{output} -o #{filename_with_path}"
        end

        # Add cover if epub
        if output == "epub" and not post.data['cover'].nil?
          output_flag << " --epub-cover-image=#{post.data['cover']}"
        end

        # The command
        pandoc = "pandoc #{flags} #{output_flag} #{extra_flags}"

        # Inform what's being done
        puts pandoc

        # Make the markdown header so pandoc receives metadata
        content  = "% #{post.data['title']}\n"
        content << "% #{post.data['author']}\n"
        content << post.content

        # Do the stuff
        Open3::popen3(pandoc) do |stdin, stdout, stderr|
          stdin.puts content
          stdin.close
        end

        # Skip failed files
        next if not File.exist? filename_with_path

        # Add them to the static files list
        site.static_files << StaticFile.new(site, base_dir, output, filename)
      end
    end
  end
end

module Converters
  # Just return html5
  class Markdown < Converter
    def convert(content)
      flags  = "#{@config['pandoc']['flags']} #{@config['pandoc']['site_flags']}"

      output = ''
      Open3::popen3("pandoc -t html5 #{flags}") do |stdin, stdout, stderr|
        stdin.puts content
        stdin.close

        output = stdout.read.strip

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
