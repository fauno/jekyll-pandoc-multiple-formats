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
  safe true

  attr_accessor :site, :config

  def generate(site)
    @site     ||= site
    @config   ||= JekyllPandocMultipleFormats::Config.new(@site.config['pandoc'])

    return if @config.skip?

    # we create a single array of files
    @pandoc_files = []

    @config.outputs.each_pair do |output, extra_flags|
      @site.posts.docs.each do |post|

        pandoc_file = PandocFile.new(@site, output, post)
        next unless pandoc_file.write

        @site.keep_files << pandoc_file.relative_path
        @pandoc_files << pandoc_file
      end

      @site.post_attr_hash('categories').each_pair do |title, posts|
        posts.sort!
        pandoc_file = PandocFile.new(@site, output, posts, title)
        next unless pandoc_file.write

        @site.keep_files << pandoc_file.relative_path
        @pandoc_files << pandoc_file
      end
    end

    @pandoc_files.each do |pandoc_file|
      # If output is PDF, we also create the imposed PDF
      if pandoc_file.pdf?

        if @config.imposition?

          imposed_file = JekyllPandocMultipleFormats::Imposition
            .new(pandoc_file.path, pandoc_file.papersize,
            pandoc_file.sheetsize, pandoc_file.signature)

          imposed_file.write
          @site.keep_files << imposed_file.relative_path(@site.dest)
        end

        # If output is PDF, we also create the imposed PDF
        if @config.binder?

          binder_file = JekyllPandocMultipleFormats::Binder
            .new(pandoc_file.path, pandoc_file.papersize,
            pandoc_file.sheetsize)

          binder_file.write
          @site.keep_files << binder_file.relative_path(@site.dest)
        end

        # Add covers to PDFs after building ready for print files
        if pandoc_file.has_cover?
          # Generate the cover
          next unless pandoc_file.pdf_cover!
          united_output = pandoc_file.path.gsub(/\.pdf\Z/, '-cover.pdf')
          united_file = JekyllPandocMultipleFormats::Unite
            .new(united_output, [pandoc_file.pdf_cover,pandoc_file.path])

          if united_file.write
            # Replace the original file with the one with cover
            FileUtils.rm_f(pandoc_file.path)
            FileUtils.mv(united_output, pandoc_file.path)
          end
        end
      end
    end
  end
end
end
