$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

TEST_PDF = File.join(File.dirname(__FILE__),'fixtures/test.pdf')
TEST_IMPOSED_PDF = File.join(File.dirname(__FILE__),'fixtures/test-imposed.pdf')
TEST_BINDER_PDF = File.join(File.dirname(__FILE__),'fixtures/test-binder.pdf')

TEST_DIR     = File.expand_path("../", __FILE__)
SOURCE_DIR   = File.expand_path("source", TEST_DIR)
DEST_DIR     = File.expand_path("destination", TEST_DIR)

require 'rubygems'
require 'minitest/autorun'
require 'shoulda'
require 'jekyll'
require 'jekyll-pandoc-multiple-formats'


# Copied from jekyll-archives (c) Alfred Xing, licensed under MIT with
# the following note:
# Taken from jekyll-mentions (Copyright (c) 2014 GitHub, Inc. Licensened under the MIT).
class Minitest::Test
  def fixture_site(config = {})
    Jekyll::Site.new(
      Jekyll::Utils.deep_merge_hashes(
        Jekyll::Utils.deep_merge_hashes(
          Jekyll::Configuration::DEFAULTS,
          {
            "source" => SOURCE_DIR,
            "destination" => DEST_DIR
          }
        ),
        config
      )
    )
  end
end
