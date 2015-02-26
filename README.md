# Another pandoc plugin for jekyll

This jekyll plugin was inspired by [jekyll-pandoc-plugin][1] but it was changed
to generate multiple outputs, rather than just using pandoc to generate jekyll
html posts. Besides, it doesn't require the 'pandoc-ruby' gem.

It's used on [En Defensa del Software Libre][0].

[0]: http://endefensadelsl.org
[1]: https://github.com/dsanson/jekyll-pandoc-plugin


## What does it do

First, it replaces the html generation for pandoc. This means you will have
support for pandoc's markdown extensions, like ~strikethrough~ and [@cite].

Second, it'll also generate the post in other formats you like, so your blog
can be made available in different formats at the same time. Epub for ebook
readers, mediawiki for copy&paste to wikis, etc.


## Configuration

Add to `_config.yml`:

    pandoc:
      skip: false
      impose: false
      output: ./tmp
      flags: '--smart --bibliography=ref.bib'
      site_flags: '--toc'
      outputs:
        pdf: '--latex-engine=latex'
        epub:
        markdown:

* `skip` allows you to skip the other formats generation and proceed with the
regular jekyll site build.

* `flags` is a string with the flags you will normally pass to `pandoc` on cli.
  It's used with all output types.

* `outputs` is a hash of output formats (even markdown!). You can add
  output-specific flags.

* `impose` creates ready to print PDFs if you're creating PDF output.

**IMPORTANT**: If you were using this plugin before 2013-07-17 you have
to change your _config.yml syntax, change pandoc.outputs from array to
hashes (see the example :)


## Front Matter

Support for epub covers has been added.  You can add the path to a cover
on the front matter of the article to have pandoc add a cover image on
the epub result.

    ---
    author: you
    title: awesome stuff
    cover: images/awesome.png
    ---

    etc...


## Layout

Add this liquid snippet on your `_layout/post.html` to generate links to the
other available formats from the post itself:

      <ul>
        {% for format in site.pandoc.outputs %}
        {% capture extension %}{{ format | first }}{% endcapture %}
        <li>
          <a href="{{ extension }}{{ page.url | remove:'.html' }}.{{ extension }}">
            {{ extension }}
          </a>
        </li>
        {% endfor %}
      </ul>

## How to install

Download a release and expand the archive, or clone the repository from GitHub. Go
into the generated directory and install as follows:

    gem build jekyll-pandoc-multiple-formats.gemspec
    gem install --local jekyll-pandoc-multiple-formats.gem

Add this snippet to your `_config.yml` on jekyll >=1.3

    gems: [ 'jekyll-pandoc-multiple-formats' ]

Alternative, see
[here](https://github.com/fauno/jekyll-pandoc-multiple-formats/issues/7).


## How to run

Execute `jekyll build` normally :D
