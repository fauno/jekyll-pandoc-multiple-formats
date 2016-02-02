require 'test_helper'

class TestPandocFile < MiniTest::Test
  context 'single post' do
    setup do
      @site = fixture_site({ 'pandoc' => { }})
      @site.read
      @pandoc_file = Jekyll::PandocFile.new(@site, 'pdf', @site.posts.docs.first)
    end

    should 'be a single post' do
      assert @pandoc_file.single_post?
    end

    should 'have a format' do
      assert_equal 'pdf', @pandoc_file.format
    end

    should 'have an extension' do
      assert @pandoc_file.path.end_with?('pdf')
    end

    should 'share the same path with different extension' do
      assert @pandoc_file.path.end_with?(@site.posts.docs.first.url.gsub(/html\Z/, 'pdf'))
    end

    should 'share the same title' do
      assert_equal @site.posts.docs.first.data['title'], @pandoc_file.title
    end

    should 'have an url' do
      assert_equal @site.posts.docs.first.url.gsub(/html\Z/, 'pdf'), @pandoc_file.url
    end

    should 'have metadata in yaml format' do
      assert @pandoc_file.yaml_metadata.start_with?('---')
      assert @pandoc_file.yaml_metadata.end_with?("---\n")
    end

    should 'have content' do
      assert @pandoc_file.content.is_a?(String)
      assert_equal @site.posts.docs.first.content, @pandoc_file.content
    end

    should 'be a pdf' do
      assert @pandoc_file.pdf?
      assert @pandoc_file.binary?
      refute @pandoc_file.epub?
    end

    should 'not have a cover' do
      refute @pandoc_file.has_cover?
      refute @pandoc_file.cover
    end

    should 'have flags' do
      assert @pandoc_file.do_flags.is_a?(String)
      assert @pandoc_file.do_flags.length > 0
    end

    should 'create a file' do
      assert @pandoc_file.write
      assert File.exists?(@pandoc_file.path)
    end

  end

  context 'several posts' do
    setup do
      @site = fixture_site({ 'pandoc' => { }})
      @site.read
      @pandoc_file = Jekyll::PandocFile.new(@site, 'pdf', @site.posts.docs, 'Multipost test')
    end

    should 'be multipost' do
      refute @pandoc_file.single_post?
    end

    should 'have a title' do
      assert_raises(ArgumentError) { Jekyll::PandocFile.new(@site, 'pdf', @site.posts.docs) }
      refute @pandoc_file.title.empty?
    end

    should 'have a path' do
      assert @pandoc_file.path.end_with?("#{@pandoc_file.slug}.#{@pandoc_file.format}")
    end

    should 'have metadata in yaml format' do
      assert @pandoc_file.yaml_metadata.start_with?('---')
      assert @pandoc_file.yaml_metadata.end_with?("---\n")
    end

    should 'create a file' do
      assert @pandoc_file.write
      assert File.exists?(@pandoc_file.path)
    end
  end
end
