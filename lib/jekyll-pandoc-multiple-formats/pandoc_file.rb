# Copyright (c) 2012-2018 Nicolás Reynolds <fauno@endefensadelsl.org>
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

    def initialize(site, format, posts, title = nil, extra = {})
      @site   = site
      @config = JekyllPandocMultipleFormats::Config.new(@site.config['pandoc']).config
      @format = format
      @flags  = []
      @last_cat = nil
      @extra = extra

      if posts.is_a? Array
        @single_post = false
        @posts = posts

        raise ArgumentError.new "'title' argument is required for multipost file" unless title

        @title = title
        @slug = Utils.slugify(@title)
      else
        @single_post = true
        @posts = [posts]
        @title = title || posts.data['title']
        @slug  = posts.data['slug']
      end

      self
    end

    def path
      # path is full destination path with all elements of permalink
      path = @site.in_dest_dir(relative_path)
    end

    def path_with_quotes
      "\"#{path}\""
    end

    def relative_path
      path = URL.unescape_path(url)
      path.gsub! /^\//, ''

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
      @url ||= if single_post?
        single_post.url.gsub(/\.html$/, ".#{@format}")
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

        # if we were to merge config to data, the default options would
        # take precedence
        data = Jekyll::Utils.deep_merge_hashes @config, single_post.data
        single_post.merge_data! data


        # we extract the excerpt because it serializes as an object and
        # breaks pandoc
        metadata = single_post.data.reject{ |k| k == 'excerpt' }

        if @config['date_format']
          metadata['date'] = metadata['date'].strftime(@config['date_format'])
        else
          metadata.delete('date')
        end
      else
        # we have to use this fugly syntax because jekyll doesn't do
        # symbols
        metadata = {
          'date'      => @config['date_format'] ? Date.today.strftime(@config['date_format']) : nil,
          'title'     => @title,
          'author'    => nil,
          'papersize' => papersize,
          'sheetsize' => sheetsize,
          'signature' => signature
        }
      end

      # fix page sizes, pandoc uses 'A4' while printer.rb uses
      # 'a4paper'
      %w[papersize sheetsize].each do |size|
        metadata[size] = fix_size metadata[size]
      end

      metadata.to_yaml << "\n---\n"
    end

    def content
      # add base url from config if we're creating a subdir site
      relative_re = /\(#{@site.config.dig('baseurl')}\/(.*)\)/
      if single_post?
        # make all images relative to source dir
        single_post.content.gsub(relative_re, '(\1)')
      else
        header_re = /^(#+.*\n*|.*\n[=-]+\n*)\Z/
        bib_title = ""
        @posts.map do |post|
          bib_title = post.content.match(header_re).to_s if bib_title.empty?
          # remove bibliography titles
          # since pandoc does it's own bibliography output, it recommends
          # leaving an empty chapter title to mark it as such
          content = post.content.gsub(header_re, '')
          # make all images relative to source dir
          content = content.gsub(relative_re, '(\1)')

          # if the file contains all the articles, we make each category
          # a different part by adding a first level title out of it
          if full?
            # make all titles down a level
            # TODO have sixth level titles into account
            content = content.gsub(/^#/, '##')

            # we don't use all the categories otherwise the article
            # would be repeated
            cat = post.data['categories'].first
            # if we already set the category part, we just skip it
            if @last_cat == cat
              content
            # otherwise add the category title
            else
              @last_cat = cat
              "# #{cat}\n\n#{content}"
            end
          else
            # or we just return the content
            content
          end
        # we add the first bibliography title we can find in the end
        end.join("\n\n\n") << bib_title
      end
    end

    def write
      FileUtils.mkdir_p(File.dirname(path))
      # Remove the file before creating it
      FileUtils.rm_f(path)
      # Move to the source dir since everything will be relative to that
      Dir::chdir(@site.config['source']) do
        # Do the stuff
        Jekyll.logger.debug command
        e = Open3::popen3(command) do |stdin, stdout, stderr, thread|
          stdin.puts yaml_metadata
          stdin.puts content
          stdin.close
          STDERR.print stderr.read

          # Wait for the process to finish
          thread.value
        end

        Jekyll.logger.warn 'Pandoc:', "Failed generating #{path}" if e.to_i > 0
      end

      File.exists?(path)
    end

    # Returns a cover, without checking if it exists
    #
    # It assumes covers are in PNG format
    def cover
      cover_path = [ @site.config['source'] ]
      if single_post? && single_post.data['cover']
        cover_path << single_post.data['cover']
      elsif site_lang?
        cover_path << @config['covers_dir']
        cover_path << site_lang
        cover_path << "#{@slug}.png"
      else
        cover_path << @config['covers_dir']
        cover_path << "#{@slug}.png"
      end

      File.join(cover_path)
    end

    def cover_with_quotes
      "\"#{cover}\""
    end

    # Returns a PDF cover
    def pdf_cover
      cover.gsub(/\.[^\.]+\Z/, '.pdf')
    end

    def pdf_cover!
      if has_cover? && !File.exists?(pdf_cover)
        Open3::popen3("convert \"#{cover}\" \"#{pdf_cover}\"") do |stdin, stdout, stderr, thread|
          STDERR.print stderr.read

          # Wait for the process to finish
          thread.value
        end
      end

      File.exists?(pdf_cover)
    end

    def flags
      return @flags.join ' ' unless @flags.empty?

      @flags << @config['flags']
      @flags << @config['outputs'][@format] if @config['outputs'].key?(@format)
      @flags << '-o'
      @flags << path_with_quotes

      # Binary formats don't need a -t flag
      unless binary?
        @flags << '-t'
        @flags << @format
      end

      if epub? && has_cover?
        @flags << '--epub-cover-image'
        @flags << cover_with_quotes
      end

      if full?
        @flags << @config['full_flags']
      end

      if site_lang?
        @flags << "-V lang=#{site_lang}"
        @flags << @config.dig('lang', site_lang, 'all')
        @flags << @config.dig('lang', site_lang, @format)
      end

      @flags.compact.join ' '
    end

    def command
      'pandoc ' << flags
    end

    def site_lang
      @site.config.dig('lang')
    end

    def site_lang?
      !site_lang.nil?
    end

    def full?
      @extra[:full]
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
      @single_post
    end

    def has_cover?
      e = File.exists? cover
      Jekyll.logger.warn "Cover:", "#{cover} missing for #{relative_path}" unless e

      e
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

    def single_post
      @posts.first
    end

    def find_option(name)
      if @posts.any? { |p| p.data.key? name }
        @posts.select { |p| p.data.key? name }.first.data[name]
      else
        @config[name]
      end
    end

    def fix_size(size)
      size.gsub /paper$/, ''
    end
  end
end
