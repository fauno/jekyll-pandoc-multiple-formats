# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll-pandoc-multiple-formats/version'

Gem::Specification.new do |gem|
  gem.name          = 'jekyll-pandoc-multiple-formats'
  gem.version       = JekyllPandocMultipleFormats::VERSION
  gem.authors       = ['Mauricio Pasquier Juan', 'Nicolás Reynolds']
  gem.email         = ['mauricio@pasquierjuan.com.ar', 'fauno@endefensadelsl.org']
  gem.description   = %q{This jekyll plugin was inspired by
  jekyll-pandoc-plugin but it was changed to generate multiple outputs,
  rather than just using pandoc to generate jekyll html posts. Besides,
  it doesn't require the 'pandoc-ruby' gem.}
  gem.summary       = %q{Use pandoc on jekyll to generate posts in multiple formats}
  gem.homepage      = 'https://github.com/fauno/jekyll-pandoc-multiple-formats'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency('jekyll', '~> 3.3.0')
  gem.add_dependency('rtex', '~> 2.1.0')
  gem.add_development_dependency('rake', '~> 10.5.0')
  gem.add_development_dependency('minitest', '~> 5.8.0')
  gem.add_development_dependency('shoulda', '~> 3.5.0')
end
