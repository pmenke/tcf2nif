# tcf2nif

![Gitlab CI Information](http://ci.streusel.org/projects/1/status.png?ref=master)

`tcf2nif` is a NLP data converter from the TCF format (used by WebLicht) to the RDF-based NIF format. At the moment, it has a limited functionality.

## License

tcf2nif is released under the GNU Lesser General Public License (version 3). See `LICENSE.txt` for details.


## Version History

### 0.2.1 - tiny correction for making CI succeed again (30 Oct 2015)

- support for a new test output directory was added, now CI succeeds again

### 0.2.0 - First working exe scripts (30 Oct 2015)

- Adds first versions of the executable scripts for doc conversions

    - __txt2tcf__ (converts plain text to TCF, using WebLicht)
    - __tcf2nif__ (converts TCF/WebLicht documents to NIF)

### 0.1.0 - Initial prototype (22 Sep 2015)

- This is the proof of concept version with minimal functionality

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tcf2nif'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tcf2nif

## Usage

See the [Jupyter notebook][notebook] for a hands-on experience and code examples.

This gem provides a proof of concept for reading TCF data (the file format used by [the WebLicht services][weblicht]).

### Reading TCF documents

In a nutshell, an instance of a TcfDocument can be obtained from any `IO` object that contains a representation of a TCF XML stream:

``` Ruby
@tcf_document = Tcf2Nif::TcfDocument.new(@io)
```

where `@io` is a Ruby IO object (a file, a stream, etc.). This TCF document can then be queried in different ways:

``` Ruby
# get the primary text
puts @tcf_document.text
# get an enumeration of Tcf2Nif::Token instances.
# these tokens contain the word form,
# and, if the respective services have been performed,
# also some annotations.
@tcf_document.tokens.each do |token|
  # do something clever with the tokens
  puts token.form
  puts token.pos?    # true iff pos annotation is present
  puts token.lemma?  # true iff lemma annotation is present
  puts token.pos     # returns the pos annotation
  puts token.lemma   # returns the lemma annotation  
end
# Depending on what is present in the TCF file,
# you can also access some other levels of annotations:
@tcf_document.geo_annotations
@tcf_document.dependency_map
```

### Conversion to NIF

The `Tcf2Nif::Transformer` class provides instances that can convert from a TCF document to an RDF graph containing NIF.

``` Ruby
@transformer = Tcf2Nif::Transformer.new(@tcf_doc, {})
graph = @trans.transform() # creates an instance of RDF::Graph
puts graph.size
RDF::Writer.open('path/to/outputfile'), :format => :ntriples) do |writer|
  writer << RDF::Repository.new do |repo|
    repo << graph
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec tcf2nif` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/tcf2nif/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[notebook]: ./Tcf2Nif.ipynb "The Tcf2Nif Jupyter Notebook"
[weblicht]: http://weblicht.sfs.uni-tuebingen.de/weblichtwiki/index.php/Main_Page
