# Jsonapi Expectations

Semantic expectation helpers for [JSON API](http://jsonapi.org/) testing using [Airborne](https://github.com/brooklynDev/airborne) and [RSpec](http://rspec.info/). It makes writing request specs fun, easy, and legible. It essentially just digs into the jsonapi response for you, so you don't need to think so much about `data`, `attributes`, `relationships`, or `includes`

## Usage

The gem includes the following matchers, which all aim to be self-explanatory

``` ruby
expect_attributes title: 'JSON API paints my bikeshed!'

expect_attributes_in_list can_find: 'attributes',  # keys are translated
                          anywhere_in_a: 'list'    # to underscored symbols

expect_relationship key: 'group',  # the name of the key under `relationships`
                    type: 'sites', # (optional) defaults to plural of key
                    id: site.id,   # find by id and/or link (at least one)
                    link: "http://www.example.com/sites/#{site.id}" 
                    included: true # look for item in `included`

expect_relationship_in_list key: 'group', # can be very succint
                            id: group.id

expect_item_count 4 # the number of items underneath the `data` key

expect_item_in_list model, type: 'people' # can set jsonapi type

expect_item_not_in_list hidden_model # infer type from model class
```


Using these helpers a spec might look something like this

```ruby
describe 'widgets' do
  let(:organization) { FactoryGirl.create :organization }
  let(:widget_attributes) { { name: 'foo' } }
  let(:widget_relations) { { 'organization' => { data: { id:  organization.id } } }

  example 'creating a widget' do
    post widgets_path, params: { data: { attributes: widget_attributes,
                                         relationships: widget_relations } }
    expect_status :ok
    expect_attributes name: widget_attributes[:name]
    expect_relationship key: 'organization',
                        link: organization_path(organization.id)
  end
end
```

## Installation

Add this line to your application's Gemfile in your test group:

```ruby
gem 'jsonapi_expectations'
```

And include it in `spec_helper.rb`

```ruby
RSpec.configure do |config|
  # ...
  config.include JsonapiExpectations, type: :request
  # ...
end
```

## Development

TODO:
- Better error/failure messages, right now they fall through to Airborne
- Flesh out test cases as examples - I have written about 200 tests using these, I know they work 😀

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Ross-Hunter/jsonapi_expectations. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

This Gem has been lovingly hand-crafted by [Ross-Hunter](http://ross-hunter.com), and built on top of the super-sweet [Airborne Gem](https://github.com/brooklynDev/airborne).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

