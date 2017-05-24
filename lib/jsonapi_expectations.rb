require 'airborne'
require 'active_support/inflector'

module JsonapiExpectations
  def expect_attributes attrs
    expect(json_body[:data]).to_not be_empty
    expect_json 'data.attributes', dasherize_keys(attrs)
  end

  def expect_attributes_absent *keys
    expect(json_body[:data]).to_not be_empty
    dasherize_array(keys).each do |key|
      expect(json_body[:data][:attributes][key].present?).to be_falsey
    end
  end

  def expect_attributes_in_list attrs
    expect(json_body[:data]).to_not be_empty
    expect_json 'data.?.attributes', dasherize_keys(attrs)
  end

  def expect_attributes_absent_in_list *keys
    expect(json_body[:data]).to_not be_empty
    dasherize_array(keys).each do |key|
      json_body[:data].each do |data|
        expect(data[key].present?).to be_falsey
      end
    end
  end

  def expect_relationship opts
    # TODO: determine if response is an array to set this, rather than passing in an option
    # If looking for item in a list, need to change location string
    location = if opts[:in_list]
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
      type = opts[:type] || opts[:key].pluralize

      if opts[:id].respond_to? :each # if an array was passed in, look for each of them
        opts[:id].each do |id|
          expect_linkage_data "#{location}.?", { type: type, id: id }, opts[:included]
        end
      else # otherwise just look for it
        expect_linkage_data location, { type: type, id: opts[:id] }, opts[:included]
      end
    end
  end

  def expect_relationship_in_list opts
    opts[:in_list] = true
    expect_relationship opts
  end

  def expect_item_count number
    expect_json_sizes data: number
  end

  def expect_record find_me, opts = {}
    opts[:type] ||= jsonapi_type find_me
    if opts[:included]
      location = json_body[:included]
    else
      location = json_body[:data]
    end
    expect(location).to_not be_empty
    found = location.detect do |item|
      jsonapi_match? find_me, item, opts[:type]
    end
    expect(found).to be_truthy
  end
  alias_method :expect_item_in_list, :expect_record

  def expect_record_absent dont_find_me, opts = {}
    opts[:type] ||= jsonapi_type dont_find_me
    if opts[:included]
      location = json_body[:included]
    else
      location = json_body[:data]
    end
    expect(location).to_not be_empty
    location.each do |item|
      expect(jsonapi_match?(dont_find_me, item, opts[:type])).to be_falsey
    end
  end
  alias_method :expect_item_not_in_list, :expect_record_absent
  alias_method :expect_item_not_to_be_in_list, :expect_record_absent
  alias_method :expect_item_to_not_be_in_list, :expect_record_absent

  ## Finder helpers

  def find_record record, opts = {}
    opts[:type] ||= jsonapi_type(record)
    if opts[:included]
      location = json_body[:included]
    else
      location = json_body[:data]
    end
    expect(location).to_not be_empty
    location.select do |item|
      jsonapi_match? record, item, opts[:type]
    end.first
  end

  private

  def expect_linkage_data location, relationship_data, included
    begin
      expect_json location, relationship_data
    rescue # check if it's in an array
      expect_json "#{location}.?", relationship_data
    end

    expect_json "included.?", relationship_data if included
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
