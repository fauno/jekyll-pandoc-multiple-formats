require 'open3'

module Jekyll

class PandocGenerator < Generator
  def generate(site)
    outputs = site.config['pandoc']['outputs']
    flags  = site.config['pandoc']['flags']

    return if site.config['pandoc']['skip']

    outputs.each do |output|

# Get the extra flags if passed on _config.yml
      extra_flags = ''
      if output.is_a?(Hash)
        extra_flags = output.values
        output = output.keys
      end

      FileUtils.mkdir_p(output)

      site.posts.each do |post|
        filename = File.join(output, post.url).gsub(/\.html$/, ".#{output}")

# Special cases, pdf and epub require -o
        if ['pdf', 'epub'].include?(output)
          output_flag = "-o #{filename}"
        else
          output_flag = "-t #{output} -o #{filename}"
        end

# Inform what's being done
        puts "pandoc #{flags} #{output_flag} #{extra_flags}"

# Do the stuff
        Open3::popen3("pandoc #{flags} #{output_flag} #{extra_flags}") do |stdin, stdout, stderr|
          stdin.puts post.content
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
