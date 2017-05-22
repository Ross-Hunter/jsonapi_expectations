require 'spec_helper'
require 'json'

RSpec.describe JsonapiExpectations do
  # Don't load from yaml everytime, will want to clean this up
  # TODO: don't use a global, you hack
  let(:json_body) { JSON_BODY }

  example "has a version number" do
    expect(JsonapiExpectations::VERSION).not_to be nil
  end

  describe 'expect_attributes' do
    context 'in list' do
      example "can find attributes" do
        expect_attributes_in_list title: 'JSON API paints my bikeshed!'
      end

      # TODO: figure out how to raise and test errors
      xexample "raises error if not found" do
        expect(expect_attributes_in_list(title: 'foo')).to raise_error
      end
    end
  end

  describe 'expect_relationship' do
    context 'in list' do
      example 'find by links' do
        expect_relationship_in_list key: 'author',
                                    link: "http://example.com/articles/1/author"
      end

      example 'find by data' do
        expect_relationship_in_list key: 'author',
                                    id: '9',
                                    type: 'people'

      end

      example 'find included items' do
        expect_relationship_in_list key: 'author',
                                    id: '9',
                                    type: 'people',
                                    included: true
      end
    end
  end

  describe 'expect_item_count' do
    example 'counts the elements inside data' do
      expect_item_count 1
    end
  end

  describe 'expect_item_in_list' do
    let(:record) { Article.new id: 1 }

    example 'finds it by type and id' do
      expect_item_in_list record
    end

    example 'can explicitly set type' do
      expect_item_in_list record, type: 'articles'
    end
  end

  describe 'expect_item_not_in_list' do
    let(:record) { Article.new id: 99999 }

    example 'searches by type, id, and link' do
      expect_item_not_in_list record
    end
  end
end
