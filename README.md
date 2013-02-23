# Easy311

Easy311 is a set of tools to ease the development of Open311 applications:
it provides a wrapper around the REST API and a close-to-compliant ActiveModel
`Request` object.

## Installation

Add this line to your application's Gemfile:

    gem 'easy311'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy311

If you want to use `Easy311::Rails`, copy and edit easy311.yml
to `#{Rails.root}/config/easy311.yml`

## Usage

The library can be used by itself without Rails, but we built a wrapper
for Rails that makes it easy to configure and load Open311's services.

No documentation official documentation has been written (yet) since
this library has originally been built during a Hackaton (see credits).

## Contributing

No contribution is too small: fork away and send pull requests!

## Credits

This gem has been extracted from 2013 [Iron Web](http://ironweb.org)
_Rouges_' team. Original code by @gelendir and @jbourassa.
