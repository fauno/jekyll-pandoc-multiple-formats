module JekyllPandocMultipleFormats
  class Config
    DEFAULTS = {
      'skip'       => false,
      'permalink'  => ':output_ext/:slug.:output_ext',
      'papersize'  => 'a5paper',
      'sheetsize'  => 'a4paper',
      'imposition' => true,
      'binder'     => true,
      'flags'      => '--smart',
      'site_flags' => '--toc',
      'outputs'    => { }
    }

    attr_accessor :config

    def initialize(config = {})
      @config = Jekyll::Utils.deep_merge_hashes(DEFAULTS, config)
    end
  end
end
