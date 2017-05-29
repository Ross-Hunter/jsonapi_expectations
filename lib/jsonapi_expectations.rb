require 'airborne'
require 'active_support/inflector'

module JsonapiExpectations
  module Exceptions
    class ExpectationError < StandardError; end
  end

  def expect_attributes attrs
    expect_valid_data
    location = if array_response?
                 'data.?.attributes'
               else
                 'data.attributes'
               end
    expect_json location, dasherize_keys(attrs)
  rescue RSpec::Expectations::ExpectationNotMetError
    msg = "Expected attributes #{attrs} to be present in json response"
    raise Exceptions::ExpectationError, msg
  end

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
  rescue RSpec::Expectations::ExpectationNotMetError
    msg = "Expected #{keys} not to be present in json response"
    raise Exceptions::ExpectationError, msg
  end

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

      if opts[:id].is_a? Array # if array was passed in, check each
        opts[:id].each do |id|
          expect_linkage_data "#{location}.?", { type: type, id: id }, opts[:included]
        end
      else # otherwise just look for it
        expect_linkage_data location, { type: type, id: opts[:id] }, opts[:included]
      end
    end
  rescue RSpec::Expectations::ExpectationNotMetError
    msg = "Expected relationship to #{type} in response"
    raise Exceptions::ExpectationError, msg
  end

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
  rescue RSpec::Expectations::ExpectationNotMetError
    msg = "Expected #{find_me} to be present in json response"
    raise Exceptions::ExpectationError, msg
  end

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
  rescue RSpec::Expectations::ExpectationNotMetError
    msg = "Expected #{dont_find_me} to not be present in json response"
    raise Exceptions::ExpectationError, msg
  end

  def expect_records_sorted_by attr, direction = :asc
    json_body[:data].each_with_index do |item, index|
      return if json_body[:data].last == item

      this_one = item[:attributes][attr]
      next_one = json_body[:data][index + 1][:attributes][attr]

      if direction == :asc
        expect(this_one).to be <= next_one
      elsif direction == :desc
        expect(next_one).to be <= this_one
      else
        raise "2nd argument needs to be :asc or :desc"
      end
    end
  rescue RSpec::Expectations::ExpectationNotMetError
    msg = "Expected response to be sorted by #{attr} #{direction}"
    raise Exceptions::ExpectationError, msg
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

  # This will go away in the 0.1.0 release
  # TODO: deprecate these
  alias expect_attributes_in_list expect_attributes
  alias expect_attributes_absent_in_list expect_attributes_absent
  alias expect_relationship_in_list expect_relationship
  alias expect_item_in_list expect_record
  alias expect_item_not_in_list expect_record_absent
  alias expect_item_not_to_be_in_list expect_record_absent
  alias expect_item_to_not_be_in_list expect_record_absent

  private

  def array_response?
    json_body[:data].is_a? Array
  end

  def expect_valid_data location = nil
    location ||= json_body[:data]
    expect(location).to_not be_nil
    expect(location).to_not be_empty
  rescue RSpec::Expectations::ExpectationNotMetError
    msg = "#{location} is does not contain data"
    raise Exceptions::ExpectationError, msg
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
