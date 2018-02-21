module JekyllPandocMultipleFormats
  class Config
    DEFAULTS = {
      'skip'              => {
        'posts' => false,
        'categories' => false,
        'full' => false
      },
      'bundle_permalink'  => ':output_ext/:slug.:output_ext',
      'papersize'         => 'a5paper',
      'sheetsize'         => 'a4paper',
      'imposition'        => true,
      'binder'            => true,
      'signature'         => 20,
      'flags'             => '--smart',
      'site_flags'        => '--toc',
      'outputs'           => {},
      'covers_dir'        => 'images/',
      'title'             => nil,
      'full_flags'        => '--top-level-division=part'
    }

    attr_accessor :config

    def initialize(config = {})
      @config = Jekyll::Utils.deep_merge_hashes(DEFAULTS, config)
    end

    def skip?
      @config['skip'].values.all?
    end

    def imposition?
      @config['imposition']
    end

    def binder?
      @config['binder']
    end

    # TODO magic
    def outputs
      @config['outputs']
    end

    def generate_posts?
      !@config.dig('skip', 'posts')
    end

    def generate_categories?
      !@config.dig('skip', 'categories')
    end

    def generate_full_file?
      !@config.dig('skip', 'full')
    end
  end
end
