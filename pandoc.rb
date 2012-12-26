require 'open3'

module Jekyll

class PandocGenerator < Generator
  def generate(site)
    outputs = site.config['pandoc']['outputs']
    flags  = site.config['pandoc']['flags']

    return if site.config['pandoc']['skip']

    outputs.each_with_index do |output, i|

# Get the extra flags if passed on _config.yml
      extra_flags = ''
      if output.is_a?(Hash)
        extra_flags = output.values.join(' ')
        output = output.keys.join(' ')
# The templates don't receive the hash
        site.config['pandoc']['outputs'][i] = output
      end

      site.posts.each do |post|

        post_path = File.join(output, File.dirname(post.url))

        puts "Creating #{post_path}"
        FileUtils.mkdir_p(post_path)

        filename = File.join(output, post.url).gsub(/\.html$/, ".#{output}")

# Special cases, stdout is disabled for these
        if ['pdf', 'epub', 'odt', 'docx'].include?(output)
          output_flag = "-o #{filename}"
        else
          output_flag = "-t #{output} -o #{filename}"
        end

# The command
        pandoc = "pandoc #{flags} #{output_flag} #{extra_flags}"

# Inform what's being done
        puts pandoc

# Make the markdown header so pandoc receives metadata
        content  = "% #{post.data['title']}\n"
        content << "% #{post.data['author']}\n"
#        content << "% #{post.date}\n\n"
        content << post.content

# Do the stuff
        Open3::popen3(pandoc) do |stdin, stdout, stderr|
          stdin.puts content
          stdin.close
        end

# Skip failed files
        next if not File.exist? filename

# Add them to the static files list
        site.static_files << StaticFile.new(site, site.source, '', filename)
      end
    end
  end
end

# Just return html5
class MarkdownConverter
  def convert(content)
    flags  = @config['pandoc']['flags']

    output = ''
    Open3::popen3("pandoc -t html5 #{flags}") do |stdin, stdout, stderr|
      stdin.puts content
      stdin.close

      output = stdout.read.strip
    end

    output

  end
end
end
