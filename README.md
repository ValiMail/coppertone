# Coppertone

[![CI](https://github.com/ValiMail/coppertone/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/ValiMail/coppertone/actions/workflows/ci.yml)

A Sender Policy Framework (SPF) toolkit for Ruby.

Coppertone includes tools for parsing SPF DNS records and evaluating the result of SPF checks for received emails. In the future the gem will build on these capabilities to allow deeper analysis of SPF configuration for hosts, senders, and domains.

## Sections

- [Install the gem](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Requirements](#requirements)
- [Review SPF scope](#specification-compliance)

## Specification Compliance

One of the challenges of writing a gem that is intended to implement a specification - especially one with as long a history as SPF - is determining exactly which version(s) and extensions to the specification the library will support.

Coppertone uses the following guidelines:

1. By default Coppertone follows [RFC 7208](http://tools.ietf.org/html/rfc7208), which is the latest revision of the SPF v1 definition and obsoletes the earlier [RFC 4408](http://tools.ietf.org/html/rfc4408). (**2026**: RFC 7208 has published errata and has been updated by later RFCs, but it remains the SPF v1 baseline.)
2. The gem explicitly does not support [RFC 4406](http://tools.ietf.org/html/rfc4406), which defines an experimental SPF v2 (Sender ID).  PR requests to add support for this functionality will be rejected.
3. Coppertone defaults to using the DNS term and lookup limits defined in [RFC 7208](http://tools.ietf.org/html/rfc7208#section-4.6.4), but makes these limits configurable.
4. Coppertone does not do TLD validation on domains encountered in SPF processing.  Domains are syntactically validated, but the TLD value is not checked against the public suffix list.

To ensure compliance with [RFC 7208](http://tools.ietf.org/html/rfc7208), Coppertone includes the latest published version of the [OpenSPF specs](http://www.openspf.org/Test_Suite) in its RSpec test suite.

If you'd like to suggest amending these guidelines, please open an issue for discussion.  Suggestions driven by real world behavior - divergences implemented by major mail server vendors or MTAs will be prioritized.

## Requirements

Coppertone requires Ruby 3.2 or newer. CI currently runs against Ruby 3.2, 3.3, and 3.4.

Coppertone does not require Rails, although it does depend on ActiveSupport.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'coppertone'
```

And then execute:
```bash
bundle
```

Or install it yourself as:
```bash
gem install coppertone
```

## Usage

To use Coppertone as a simple SPF checker (as you might, for example, if you were bundling it in a receiving SMTP server), you may use the `Coppertone::SpfService.authenticate_email` method.

For example, were you authenticating an email sent by an SMTP server with IP address 1.2.3.4, advertising a HELO domain of 'mailserver123.example.org' and sent from 'somerandomperson@example.org', you'd invoke the method as follows:

```ruby
result = Coppertone::SpfService.authenticate_email(
  '1.2.3.4',
  'somerandomperson@example.org',
  'mailserver123.example.org'
)
```

which would yield an instance of `Coppertone::Result` with the appropriate result code, and any explanation message.  If the email was validated, then this result will also include the validating mechanism and the validated identity ('helo' or 'mailfrom').

For example:

```ruby
result.code        # => :pass
result.pass?       # => true
result.identity    # => 'mailfrom'
result.mechanism   # => #<Coppertone::Mechanism::IP4 ...>
result.explanation # => nil
result.problem     # => nil
```

For more sophisticated use of Coppertone, please consult the code and corresponding documentation directly.

## Configuration

Coppertone can be configured globally:

```ruby
Coppertone.config.hostname = 'mx.example.org'
Coppertone.config.default_explanation = 'SPF check failed'
Coppertone.config.terms_requiring_dns_lookup_limit = 10
Coppertone.config.void_dns_result_limit = 2
Coppertone.config.dns_lookups_per_mx_mechanism_limit = 10
Coppertone.config.dns_lookups_per_ptr_mechanism_limit = 10
Coppertone.config.dns_client_class = DNSAdapter::ResolvClient
```

DNS clients, hostnames, locales, and lookup limits can also be provided per request:

```ruby
result = Coppertone::SpfService.authenticate_email(
  '1.2.3.4',
  'somerandomperson@example.org',
  'mailserver123.example.org',
  dns_client: DNSAdapter::ResolvClient.new,
  hostname: 'mx.example.org',
  message_locale: 'en',
  terms_requiring_dns_lookup_limit: 10,
  void_dns_result_limit: 2
)
```

By default, Coppertone uses `DNSAdapter::ResolvClient` for DNS lookups and the RFC 7208 lookup limits. The default explanation for SPF failures is configured globally with `Coppertone.config.default_explanation`.

## Contributing

We actively seek contributions from the Coppertone community to make this the best possible gem. Users can contribute by creating a pull request with the requested changes.

Some guidelines:

1. The scope of this gem is limited to the Sender Policy Framework.  New functionality should be restricted to features directly relevant to SPF.
2. PRs that add functionality or fix bugs must include test coverage for the new functionality or fixed bug.  PRs that don't include such test coverage will not be merged.
3. PRs should not break existing specs unintentionally.  Only PRs that run green will be merged to `main`.
4. Similarly, PRs should not introduce new `Rubocop` violations.
5. Please run `bundle exec rake` before submitting your PR and ensure it runs clean.
