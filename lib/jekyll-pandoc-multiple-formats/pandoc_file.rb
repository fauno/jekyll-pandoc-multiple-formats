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
  class PandocFile
    include Convertible


    attr_reader :format, :site, :config, :flags, :posts, :slug, :title, :url
    attr_reader :papersize, :sheetsize, :signature

    def initialize(site, format, posts, title = nil)
      @site   = site
      @config = JekyllPandocMultipleFormats::Config.new(@site.config['pandoc']).config
      @format = format
      @flags  = []

      if posts.is_a? Array
        @posts = posts

        raise ArgumentError.new "'title' argument is required for multipost file" unless title

        @title = title
        @slug  = Utils.slugify(title)
      else
        @posts = [posts]
        @slug  = posts.data['slug']
        @title = posts.data['title'] unless title
      end
    end

    def path
      # path is full destination path with all elements of permalink
      path = @site.in_dest_dir(URL.unescape_path(url))

      # but if the post is going to be index.html, use slug + format
      # (ie /year/month/slug/slug.pdf)
      if url.end_with? '/'
        path = File.join(path, @slug)
        path << '.'
        path << @format
      end

      path
    end

    # if it's just one article, the url is the same except it's not html
    # otherwise we use the permalink template with some placeholder
    def url
      @url = if single_post?
        @posts.first.url.gsub(/\.html$/, ".#{@format}")
      else
        URL.new({
          template: @config['bundle_permalink'],
          placeholders: url_placeholders,
          permalink: nil }).to_s
      end
    end

    def url_placeholders
      { output_ext: @format,
        slug: @slug,
        title: @title }
    end

    # adds post metadata as yaml metadata
    def yaml_metadata
      if single_post?
        if @config['date_format']
          @posts.first.data['date'] = @posts.first.data['date'].strftime(@config['date_format'])
        else
          @posts.first.data.delete('date')
        end

        Jekyll::Utils.deep_merge_hashes! @posts.first.data, @config

        # we extract the excerpt because it serializes as an object and
        # breaks pandoc
        metadata = @posts.first.data.reject{ |k| k == 'excerpt' }
      else
        metadata = {
          date: @config['date_format'] ? Date.today.strftime(@config['date_format']) : nil,
          title: @title,
          author: nil,
          papersize: papersize,
          sheetsize: sheetsize,
          signature: signature
        }
      end

      metadata.to_yaml << "\n---\n"
    end

    def content
      @posts.map do |post|
        # remove bibliography titles
        post.content.gsub(/^#+.*\n*\Z/, '').gsub(/^.*\n[=-]+\n*\Z/, '')
      end.join "\n\n\n"
    end

    def write
      puts "Writing #{path}"
      FileUtils.mkdir_p(File.dirname(path))
      # Remove the file before creating it
      FileUtils.rm_f(path)
      # Move to the source dir since everything will be relative to that
      Dir::chdir(@site.config['source']) do
        # Do the stuff
        Open3::popen3(do_command) do |stdin, stdout, stderr, thread|
          stdin.puts yaml_metadata
          stdin.puts content
          stdin.close
          STDERR.print stderr.read

          # Wait for the process to finish
          thread.value
        end
      end

      File.exists?(path)
    end

    def cover
      @posts.select { |p| p.data.key? 'cover' }.first.data['cover'] if has_cover?
    end

    def do_flags
      @flags << @config['flags']
      @flags << @config['outputs'][@format] if @config['outputs'].key?(@format)
      @flags << '-o'
      @flags << path

      # Binary formats don't need a -t flag
      unless binary?
        @flags << '-t'
        @flags << @format
      end

      if epub? && has_cover?
        @flags << '--epub-cover-image'
        @flags << cover
      end

      @flags.join ' '
    end

    def do_command
      'pandoc ' << do_flags
    end

    def pdf?
      @format == 'pdf'
    end

    def epub?
      %w[epub epub3].include? @format
    end

    # These formats are binary files and must use the -o flag
    def binary?
      %w[pdf epub epub3 odt docx].include? @format
    end

    def single_post?
      @posts.count == 1
    end

    def has_cover?
      @posts.any? { |p| p.data.key? 'cover' }
    end

    def papersize
      @papersize ||= find_option 'papersize'
    end

    def sheetsize
      @sheetsize ||= find_option 'sheetsize'
    end

    def signature
      @signature ||= find_option 'signature'
    end

    private

    def find_option(name)
      if @posts.any? { |p| p.data.key? name }
        @posts.select { |p| p.data.key? name }.first.data[name]
      else
        @config[name]
      end
    end
  end
end
