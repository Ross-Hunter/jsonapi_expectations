require 'spec_helper'
require 'json'

RSpec.describe JsonapiExpectations do
  let(:json_body) do
    JSON.parse(IO.read("spec/test_responses/jsonapi.json"),
               symbolize_names: true)
  end

  example "has a version number" do
    expect(JsonapiExpectations::VERSION).not_to be nil
  end

  example "can find attributes in the list" do
    expect_attributes_in_list title: 'JSON API paints my bikeshed!'
  end

  example 'can find relationships by links' do
    expect_relationship key: 'author',
                        link: "http://example.com/articles/1/author",
                        in_list: true
  end

  example 'can find relationships by data' do
    expect_relationship key: 'author',
                        id: '9',
                        type: 'people',
                        in_list: true

  end
end
