gbif
=========

[![gem version](https://img.shields.io/gem/v/gbif.svg)](https://rubygems.org/gems/gbif)
[![Build Status](https://api.travis-ci.org/sckott/gbif.png)](https://travis-ci.org/sckott/gbif)
[![codecov.io](http://codecov.io/github/sckott/gbif/coverage.svg?branch=master)](http://codecov.io/github/sckott/gbif?branch=master)
[![DOI](https://zenodo.org/badge/2600/sckott/gbif.svg)](https://zenodo.org/badge/latestdoi/2600/sckott/gbif)

`gbif` is a low level client for the GBIF API

Other GBIF API clients:

- Python: [pygbif](https://github.com/sckott/pygbif)
- R: [rgbif](https://github.com/ropensci/rgbif)

## Changes

For changes see the [Changelog][changelog]

## API

Methods in relation to [GBIF API][gbifapi] routes

* `/works` - `gbif.works()`
* `/members` - `gbif.members()`
* `/prefixes` - `gbif.prefixes()`
* `/funders` - `gbif.funders()`
* `/journals` - `gbif.journals()`
* `/licenses` - `gbif.licenses()`
* `/types` - `gbif.types()`

## Install

### Release version

```
gem install gbif
```

### Development version

```
git clone git@github.com:sckott/gbif.git
cd gbif
rake install
```

## Examples

### Use in a Ruby repl

Search for species

```ruby
require 'gbif'
gbif.species.name_backbone(ids: '10.1371/journal.pone.0033693')
```

Search works by query string

```ruby
gbif.works(query: "ecology")
```

Search journals by publisher name

```ruby
gbif.journals(query: "peerj")
```

Search funding information by DOI

```ruby
gbif.funders(ids: ['10.13039/100000001','10.13039/100000015'])
```

Get agency for a set of DOIs

```ruby
gbif.registration_agency(ids: ['10.1007/12080.1874-1746','10.1007/10452.1573-5125'])
```

Get random set of DOIs

```ruby
gbif.random_dois(sample: 100)
```

Content negotiation

```ruby
gbif.content_negotiation(ids: '10.1126/science.169.3946.635', format: "citeproc-json")
```

### Use on the CLI

The command line tool `gbif` should be available after you install

```
~$ gbif
Commands:
  gbif contneg                   # Content negotiation
  gbif funders [funder IDs]      # Search for funders by DOI prefix
  gbif help [COMMAND]            # Describe available commands or one spec...
  gbif journals [journal ISSNs]  # Search for journals by ISSNs
  gbif licenses                  # Search for licenses by name
  gbif members [member IDs]      # Get members by id
  gbif prefixes [DOI prefixes]   # Search for prefixes by DOI prefix
  gbif types [type name]         # Search for types by name
  gbif version                   # Get gbif version
  gbif works [DOIs]              # Get works by DOIs
```

```
# A single DOI
~$ gbif works 10.1371/journal.pone.0033693

# Many DOIs
~$ gbif works "10.1007/12080.1874-1746,10.1007/10452.1573-5125"

# output JSON, then parse with e.g., jq
~$ gbif works --filter=has_orcid:true --json --limit=2 | jq '.message.items[].author[].ORCID | select(. != null)'
```

## Meta

* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
* License: MIT

[gbifapi]: https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md
[cn]: http://www.crosscite.org/cn/
[tdm]: http://www.crossref.org/tdm/
[ccount]: http://labs.crossref.org/openurl/
[csl]: https://github.com/citation-style-language/styles
[changelog]: https://github.com/sckott/gbif/blob/master/CHANGELOG.md
