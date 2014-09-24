# Coppertone

[![Build Status](https://travis-ci.org/petergoldstein/coppertone.svg?branch=master)](https://travis-ci.org/petergoldstein/coppertone)
[![Test Coverage](https://codeclimate.com/github/petergoldstein/coppertone/badges/coverage.svg)](https://codeclimate.com/github/petergoldstein/coppertone)
[![Code Climate](https://codeclimate.com/github/petergoldstein/coppertone/badges/gpa.svg)](https://codeclimate.com/github/petergoldstein/coppertone)

A Sender Policy Framework (SPF) toolkit for Ruby.

Coppertone includes tools for parsing SPF DNS records, evaluating the result of SPF checks for received emails, and creating appropriate email headers from the SPF result.  In the future the gem will build on these capabilities to allow deeper analysis of SPF configuration for hosts, senders, and domains.

## Specification Compliance

One of the challenges of writing a gem that is intended to implement a specification - especially one with as long a history as SPF - is determining exactly which version(s) and extensions to the specification the library will support.  Coppertone uses the following guidelines:

1. By default Coppertone follows [RFC 7208](http://tools.ietf.org/html/rfc7208), which is the latest revision of the SPF v1 definition and obsoletes the earlier [RFC 4408](http://tools.ietf.org/html/rfc4408)
2. The gem explicitly does not support [RFC 4406](http://tools.ietf.org/html/rfc4406), which defines an experimental SPF v2 (Sender ID).  PR requests to add support for this functionality will be rejected.
3. Coppertone defaults to using the DNS term and lookup limits defined in [RFC 7208](http://tools.ietf.org/html/rfc7208#section-4.6.4), but makes these limits configurable.
4. Coppertone does not do TLD validation on domains encountered in SPF processing.  Domains are syntactically validated, but the TLD value is not checked against the public access list.

If you'd like to suggest amending these guidelines, please open an issue for discussion.  Suggestions driven by real world behavior - divergences implemented by major mail server vendors or MTAs will be prioritized.

## Requirements

Coppertone supports MRI 2.0 and up - earlier MRI rubies are not supported.  JRuby and Rubinius support is planned, but these VMs are not currently supported.

Coppertone does not require Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'coppertone'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coppertone

## Usage

TODO: Write usage instructions here

## Contributing

We actively seek contributions from the Coppertone community to make this the best possible gem.  Users can contribute by creating a pull request with the requested changes.

Some guidelines:

1. The scope of this gem is limited to the Sender Policy Framework.  New functionality should be restricted to features directly relevant to SPF.
2. PRs that add functionality or fix bugs must include test coverage for the new functionality or fixed bug.  PRs that don't include such test coverage will not be merged.
3. PRs should not break existing specs unintentionally.  Only PRs that run green will be merged to master.
4. Similarly, PRs should not introduce new Rubocop violations.
5. Please run `bundle exec rake` before submitting your PR and ensure it runs clean.  This will help ensure against inadvertent spec breakage or Rubocop violations.