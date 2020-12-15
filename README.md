gbifrb
======

[![gem version](https://img.shields.io/gem/v/gbifrb.svg)](https://rubygems.org/gems/gbifrb)
[![Ruby](https://github.com/sckott/gbifrb/workflows/Ruby/badge.svg)](https://github.com/sckott/gbifrb/actions?query=workflow%3ARuby)
[![codecov.io](http://codecov.io/github/sckott/gbifrb/coverage.svg?branch=master)](http://codecov.io/github/sckott/gbifrb?branch=master)

`gbifrb` is a low level client for the GBIF API

Other GBIF API clients:

- Python: [pygbif](https://github.com/sckott/pygbif)
- R: [rgbif](https://github.com/ropensci/rgbif)

## Changes

For changes see the [Changelog][changelog]

## API

Methods in relation to [GBIF API][gbifapi] routes

registry

* `/node` - `Gbif::Registry.nodes`
* `/network` - `Gbif::Registry.networks`
* `/installations` - `Gbif::Registry.installations`
* `/organizations` - `Gbif::Registry.organizations`
* `/dataset_metrics` - `Gbif::Registry.dataset_metrics`
* `/datasets` - `Gbif::Registry.datasets`
* `/dataset_suggest` - `Gbif::Registry.dataset_suggest`
* `/dataset_search` - `Gbif::Registry.dataset_search`

species

* `/species/match` - `Gbif::Species.name_backbone`
* `/species/suggest` - `Gbif::Species.name_suggest`
* `/species/search` - `Gbif::Species.name_lookup`
* `/species` - `Gbif::Species.name_usage`

occurrences

* `/search` - `Gbif::Occurrences.search`
* `/get` - `Gbif::Occurrences.get`
* `/get_verbatim` - `Gbif::Occurrences.get_verbatim`
* `/get_fragment` - `Gbif::Occurrences.get_fragment`


## Install

### Release version

```
gem install gbifrb
```

### Development version

```
git clone git@github.com:sckott/gbifrb.git
cd gbifrb
rake install
```

## Examples, in Ruby repl

### Registry module

Nodes

```ruby
require 'gbifrb'
registry = Gbif::Registry
registry.nodes(limit: 5)
```

Networks

```ruby
registry.networks(uuid: '16ab5405-6c94-4189-ac71-16ca3b753df7')
```

### Species module

GBIF backbone

```ruby
species = Gbif::Species
species.name_backbone(name: "Helianthus")
```

Suggester

```ruby
species.name_suggest("Helianthus")
```

### Occurrences

```ruby
occ = Gbif::Occurrences
occ.search(taxonKey: 3329049)
occ.search(taxonKey: 3329049, limit: 2)
occ.search(scientificName: 'Ursus americanus')
```

### curl options

```ruby
species = Gbif::Species
species.name_backbone("Helianthus", verbose: true)
```

### Todo

* CLI interface
* occurrence metrics methods
* occurrence downloads methods
* OAI-PMH interface

## Meta

* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
* License: MIT

[gbifapi]: https://www.gbif.org/developer/summary
[changelog]: https://github.com/sckott/gbifrb/blob/master/CHANGELOG.md
