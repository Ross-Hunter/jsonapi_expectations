require 'airborne'
require 'active_support/inflector'

module JsonapiExpectations
  def expect_attributes attrs
    expect(json_body[:data]).to_not be_empty
    expect_json 'data.attributes', dasherize_keys(attrs)
  end

  def expect_attributes_in_list attrs
    expect(json_body[:data]).to_not be_empty
    expect_json 'data.?.attributes', dasherize_keys(attrs)
  end

  def expect_relationship opts
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

  def expect_item_in_list find_me, opts = {}
    opts[:type] ||= jsonapi_type find_me
    expect(json_body[:data]).to_not be_empty
    found = json_body[:data].detect do |item|
      jsonapi_match? find_me, item, opts[:type]
    end
    expect(found).to be_truthy
  end

  def expect_item_not_in_list dont_find_me, opts = {}
    opts[:type] ||= jsonapi_type dont_find_me
    expect(json_body[:data]).to_not be_empty
    json_body[:data].each do |item|
      expect(jsonapi_match?(dont_find_me, item, opts[:type])).to be_falsey
    end
  end
  alias_method :expect_item_not_to_be_in_list,
               :expect_item_not_in_list
  alias_method :expect_item_to_not_be_in_list,
               :expect_item_not_in_list

  ## Finder helpers

  def find_record_in_response record, opts = {}
    opts[:type] ||= jsonapi_type(record)
    json_body[:data].select do |item|
      item[:id]&.to_s == record.id&.to_s && item[:type] == opts[:type]
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

  def dasherize_keys hash
    hash.deep_transform_keys { |key| key.to_s.tr('_', '-').to_sym }
  end

  def jsonapi_match? model, data, type
    (data[:type] == type) && (data[:id] == model.id.to_s)
  end

  def jsonapi_type model
    model.class.to_s.underscore.downcase.pluralize.tr('_', '-')
  end
end
