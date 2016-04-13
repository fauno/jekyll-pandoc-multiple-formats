module JekyllPandocMultipleFormats
  class Config
    DEFAULTS = {
      'skip'              => false,
      'bundle_permalink'  => ':output_ext/:slug.:output_ext',
      'papersize'         => 'a5paper',
      'sheetsize'         => 'a4paper',
      'imposition'        => true,
      'binder'            => true,
      'signature'         => 20,
      'flags'             => '--smart',
      'site_flags'        => '--toc',
      'outputs'           => {},
      'covers_dir'        => 'images/'
    }

    attr_accessor :config

    def initialize(config = {})
      @config = Jekyll::Utils.deep_merge_hashes(DEFAULTS, config)
    end

    def skip?
      @config['skip']
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
  end
end
