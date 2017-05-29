# Jsonapi Expectations

[![CircleCI](https://circleci.com/gh/Ross-Hunter/jsonapi_expectations/tree/master.svg?style=svg)](https://circleci.com/gh/Ross-Hunter/jsonapi_expectations/tree/master)

Semantic expectation helpers for [JSON API](http://jsonapi.org/) testing using [Airborne](https://github.com/brooklynDev/airborne) and [RSpec](http://rspec.info/). It makes writing request specs fun, easy, and legible. It essentially just digs into the jsonapi response for you, so you don't need to worry so much about `data`, `attributes`, `relationships`, or `includes`

## Usage

The gem includes the following matchers, which all aim to be self-explanatory

``` ruby
expect_attributes title: 'JSON API paints my bikeshed!',
                  can_find: 'attributes',     # keys are translated to
                  anywhere_under: 'data key', # underscored symbols
                  works_on_array_response: 'or just a single object' 

expect_attributes_absent cost: 'allows testing field-level permissions'

expect_relationship key: 'group',  # the name of the key under `relationships`
                    type: 'sites', # (optional) defaults to plural of key
                    id: site.id,   # find by id and/or link (at least one)
                    link: "http://www.example.com/sites/#{site.id}" 
                    included: true # look for item in `included`

expect_record model, type: 'people' # can set jsonapi type

expect_record_absent hidden_model # infer type from model class

expect_records_sorted_by :ranking, :desc # defaut is :asc

find_record model # grab the record for more in-depth testing of the response

expect_item_count 4 # the number of items underneath the `data` key
```


Using these helpers a spec might look something like this

```ruby
describe 'widgets' do
  let(:org) { FactoryGirl.create :organization }
  let(:widgets) { FactoryGirl.create_list :widget, 4, organization: org }
  let(:widget) { widgets.first }
  let(:widget_attributes) { { name: 'foo' } }
  let(:widget_relations) { { organization: { data: { id: org.id } } }

  example 'creating a widget' do
    post widgets_path, params: { data: { attributes: widget_attributes,
                                         relationships: widget_relations } }
    expect_status :created
    expect_attributes name: widget_attributes[:name]
    expect_relationship key: 'organization',
                        link: organization_path(org.id)
  end

  example 'getting widgets with included organization' do
    widgets
    get widgets_path, params: { include: 'organization' }

    expect_status :ok
    expect_record widget
    expect_record organization, included: true
    expect_records_sorted_by :price

    found_widget = find_record widget
    found_org = find_record org, included: true
    expect(found_widget.organization).to eq(found_org)
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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Ross-Hunter/jsonapi_expectations. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

This Gem has been lovingly hand-crafted by [Ross-Hunter](http://ross-hunter.com), and built on top of the super-sweet [Airborne Gem](https://github.com/brooklynDev/airborne).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

