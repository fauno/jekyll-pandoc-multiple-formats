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
      flags: '--smart --bibliography=ref.bib'
      outputs:
        - pdf: '--latex-engine=latex'
        - epub
        - markdown

* `skip` allows you to skip the other formats generation and proceed with the
regular jekyll site build.

* `flags` is a string with the flags you will normally pass to `pandoc` on cli.
  It's used with all output types.

* `outputs` is an array of output formats (even markdown!). You can add
  output-specific flags as a hash.

## Layout

Add this liquid snippet on your `_layout/post.html` to generate links to the
other available formats from the post itself:

    <li>
    {% for format in site.pandoc.outputs %}
            <li><a href="{{ format }}/{{ page.url | replace:'html',format }}">{{ format }}</a></li>
    {% endfor %}
    </li>

## How to run

Execute `jekyll` normally :D
