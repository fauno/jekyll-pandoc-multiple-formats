# Another pandoc plugin for jekyll

This jekyll plugin was inspired by [jekyll-pandoc-plugin][1] but it was changed
to generate multiple outputs, rather than just using pandoc to generate jekyll
html posts. Besides, it doesn't require the 'pandoc-ruby' gem.

It's used on [En Defensa del Software Libre][0]. Please check [our
repo](https://github.com/edsl/endefensadelsl.org) if you like to see how
it works in production.

[0]: http://endefensadelsl.org
[1]: https://github.com/dsanson/jekyll-pandoc-plugin


## What does it do

It replaces the html generation for pandoc. This means you will have
support for pandoc's markdown extensions, like ~strikethrough~ and
[@cite], tables and [a lot more stuff](http://pandoc.org/README.html).

It'll also generate the post in other formats you like, so your
blog can be made available in different formats at the same time. Epub
for ebook readers, mediawiki for copy&paste to wikis, etc.

If instructed, this plugin will also generate pdfs in ready for print
format.


## Configuration

Add to `_config.yml`:

```yaml

markdown: pandoc
pandoc:
    skip: false
    bundle_permalink: ':output_ext/:slug.:output_ext'
    papersize: 'a5paper'
    sheetsize: 'a4paper'
    imposition: true
    binder: true
    covers_dir: assets/covers

    flags: '--smart'
    site_flags: '--toc'
    outputs:
      latex:
      pdf: '--latex-engine=xelatex'
      epub: '--epub-chapter-level=2'

```

* `markdown: pandoc` will instruct jekyll to use the pandoc html
  converter.

* `skip` allows you to skip the other formats generation and proceed with the
regular jekyll site build.

* `site_flags` are flags applied to the html generation

* `flags` is a string with the flags you will normally pass to `pandoc` on cli.
  It's used on all output types.

* `outputs` is a hash of output formats (even markdown!). You can add
  output-specific flags.

* `imposition` creates ready to print PDFs if you're creating PDF
  output.

* `binder` creates ready to print PDFs 

* `bundle_permalink` is the path of the bundled articles

* `papersize` is the page size for PDF

* `sheetsize` is the page size for ready the print PDF

* `covers_dir` the directory where covers are stored

**IMPORTANT**: As of version 0.1.0 the syntax of the config changed.
Please upgrade your `_config.yml` accordingly.


## Front Matter

### Covers

Support for epub covers has been added.  You can add the path to
a cover on the front matter of the article to have pandoc add a cover
image on the epub result.

    ---
    cover: images/awesome.png
    ---

For categories or posts without a cover specified, the plugin looks for
a PNG file inside the `covers_dir` whose file name will be the
category/post slug.

Since 0.2.0, there's also support for PDF covers.  If you have a PNG
cover, it will get converted to PDF.  You can also provide a PDF cover
as long as it's the same file name as the PNG cover.

* Category cover: `assets/covers/the_category_slug.png`
* PDF cover: `assets/covers/the_slug.pdf`

### Paper sizes

For PDFs, each article can have a `papersize` and a `sheetsize`.  The
`papersize` indicates the page size, and the `sheetsize` indicates the
pages per fold size.

Only A* sizes from A7 to A0 are supported for now.

    ---
    papersize: a5paper
    sheesize: a4paper
    ---

This example will generate a 2 pages per A4 sheet.

### Bundled articles

If articles share a category, the generator will create a PDF book
including all of them.  The name of the category will become the title
of the book.

    ---
    category: [ 'En Defensa del Software Libre #0' ]
    ---

The papersize will be the `papersize` of the first article found or the
default papersize on the `_config.yml` file.  Same applies for
`sheetsize`.

NOTE: Authorship will be set to empty.  This could change in the future.

## Bibliography

If you have bibliography, pandoc recommends leaving an empty
section at the end of the document if you want to have a separate
section for it. For bundled articles, this plugin will remove the extra
sections and create one for everything at the end.

    # Bibliography
    
    <EOF>

You can also use the underlined version of the section title (aka
`settext style` vs `atx style`).


## Layout

Add this liquid snippet on your `_layout/post.html` to generate links to the
other available formats from the post itself:

      <ul>
        {% for format in site.pandoc.outputs %}
        {% capture extension %}{{ format | first }}{% endcapture %}
        <li>
          <a href="{{ page.url | remove:'.html' }}.{{ extension }}">
            {{ extension }}
          </a>
        </li>
        {% endfor %}
      </ul>

## How to install

Add this snippet to your `_config.yml` on jekyll 1.3

    gems: [ 'jekyll-pandoc-multiple-formats' ]

Alternative, see
[here](https://github.com/fauno/jekyll-pandoc-multiple-formats/issues/7).


## How to run

Execute `jekyll build` normally :D

