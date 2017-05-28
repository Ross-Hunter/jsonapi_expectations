require 'airborne'
require 'active_support/inflector'
require_relative './jsonapi_expectations/exceptions'

module JsonapiExpectations
  def expect_attributes attrs
    expect_valid_data
    location = if array_response?
                 'data.?.attributes'
               else
                 'data.attributes'
               end
    expect_json location, dasherize_keys(attrs)
  rescue RSpec::Expectations::ExpectationNotMetError => e
    message = "Expected attributes #{attrs} to be present in json response"
    raise JsonapiExpectations::Exceptions::ExpectationError, message
  end
  alias expect_attributes_in_list expect_attributes

  def expect_attributes_absent *keys
    expect_valid_data
    if array_response?
      json_body[:data].each do |data|
        dasherize_array(keys).each do |key|
          expect(data[:attributes].key?(key)).to be_falsey
        end
      end
    else
      dasherize_array(keys).each do |key|
        expect(json_body[:data][:attributes].key?(key)).to be_falsey
      end
    end
  rescue RSpec::Expectations::ExpectationNotMetError => e
    message = "Expected #{keys} not to be present in json response"
    raise JsonapiExpectations::Exceptions::ExpectationError, message
  end
  alias expect_attributes_absent_in_list expect_attributes_absent

  def expect_relationship opts
    expect_valid_data
    type = opts[:type] || opts[:key].pluralize
    location = if array_response?
                 "data.?.relationships.#{opts[:key]}"
               else
                 "data.relationships.#{opts[:key]}"
               end

    if opts[:link]
      begin
        expect_json "#{location}.links.related", opts[:link]
      rescue # check if it's in an array
        expect_json "#{location}.?.links.related", opts[:link]
      end
    end

    if opts[:id]
      location = "#{location}.data"

      if opts[:id].respond_to? :each # if an array was passed in, look for each of them
        opts[:id].each do |id|
          expect_linkage_data "#{location}.?", { type: type, id: id }, opts[:included]
        end
      else # otherwise just look for it
        expect_linkage_data location, { type: type, id: opts[:id] }, opts[:included]
      end
    end
  rescue RSpec::Expectations::ExpectationNotMetError => e
    message = "Expected relationship to #{type} in response"
    raise JsonapiExpectations::Exceptions::ExpectationError, message
  end
  alias expect_relationship_in_list expect_relationship

  def expect_item_count number
    expect_valid_data
    expect_json_sizes data: number
  end

  def expect_record find_me, opts = {}
    opts[:type] ||= jsonapi_type find_me
    location = if opts[:included]
                 json_body[:included]
               else
                 json_body[:data]
               end
    expect_valid_data location
    found = location.detect do |item|
      jsonapi_match? find_me, item, opts[:type]
    end
    expect(found).to be_truthy
  rescue RSpec::Expectations::ExpectationNotMetError => e
    message = "Expected #{find_me} to be present in json response"
    raise JsonapiExpectations::Exceptions::ExpectationError, message
  end
  alias expect_item_in_list expect_record

  def expect_record_absent dont_find_me, opts = {}
    opts[:type] ||= jsonapi_type dont_find_me
    location = if opts[:included]
                 json_body[:included]
               else
                 json_body[:data]
               end
    expect_valid_data location
    location.each do |item|
      expect(jsonapi_match?(dont_find_me, item, opts[:type])).to be_falsey
    end
  rescue RSpec::Expectations::ExpectationNotMetError => e
    message = "Expected #{dont_find_me} to not be present in json response"
    raise JsonapiExpectations::Exceptions::ExpectationError, message
  end
  alias expect_item_not_in_list expect_record_absent
  alias expect_item_not_to_be_in_list expect_record_absent
  alias expect_item_to_not_be_in_list expect_record_absent

  def expect_valid_data location = nil
    location ||= json_body[:data]
    expect(location).to_not be_nil
    expect(location).to_not be_empty
  rescue RSpec::Expectations::ExpectationNotMetError => e
    message = "#{location} is does not contain data"
    raise JsonapiExpectations::Exceptions::ExpectationError, message
  end

  def find_record record, opts = {}
    opts[:type] ||= jsonapi_type(record)
    location = if opts[:included]
                 json_body[:included]
               else
                 json_body[:data]
               end
    expect_valid_data location
    location.select do |item|
      jsonapi_match? record, item, opts[:type]
    end.first
  end

  private

  def array_response?
    json_body[:data].is_a? Array
  end

  def expect_linkage_data location, relationship_data, included
    begin
      expect_json location, relationship_data
    rescue # check if it's in an array
      expect_json "#{location}.?", relationship_data
    end

    expect_json 'included.?', relationship_data if included
  end

  def dasherize_array array
    array.map { |item| dasherize item }
  end

  def dasherize_keys hash
    hash.deep_transform_keys { |key| dasherize key }
  end

  def dasherize thing
    thing.to_s.tr('_', '-').to_sym
  end

  def jsonapi_match? model, data, type
    (data[:type] == type) && (data[:id] == model.id.to_s)
  end

  def jsonapi_type model
    model.class.to_s.underscore.downcase.pluralize.tr('_', '-')
  end
end
