require 'spec_helper'
require 'json'

RSpec.describe JsonapiExpectations do
  # Don't load from yaml everytime
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

      # TODO: raise and test our own errors
      example "raises error if not found" do
        expect{
          expect_attributes_in_list title: 'foo'
        }.to raise_error
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

  describe 'expect_record' do
    context 'when present' do
      let(:record) { Article.new id: 1 }
      let(:included) { People.new id: 9 }

      example 'finds it by type and id' do
        expect_record record
      end

      example 'can explicitly set type' do
        expect_record record, type: 'articles'
      end

      example 'can find included records' do
        expect_record included, type: 'people', included: true
      end
    end

    context 'when absent' do
      let(:record) { Article.new id: 99999 }

      example 'finds it by type and id' do
        expect{
          expect_record record
        }.to raise_error
      end

      example 'can explicitly set type' do
        expect{
          expect_record record, type: 'articles'
        }.to raise_error
      end
    end
  end

  describe 'expect_record_absent' do
    context 'when present' do
      let(:record) { Article.new id: 99999 }

      example 'searches by type, id, and link' do
        expect_record_absent record
      end
    end

    context 'when absent' do
      let(:record) { Article.new id: 1 }

      example 'searches by type, id, and link' do
        expect{
          expect_record_absent record
        }.to raise_error
      end
    end
  end

  describe 'find_record' do

    context 'when present' do
      let(:record) { Article.new id: 1 }
      let(:included) { People.new id: 9 }

      example 'finds it by type and id' do
        found = find_record record
        expect(found).to be
        expect(found[:attributes][:title]).to eq("JSON API paints my bikeshed!")
      end

      example 'can find included objects' do
        found = find_record included, type: 'people', included: true
        expect(found).to be
        expect(found[:attributes][:"first-name"]).to eq("Dan")
      end
    end

    context 'when absent' do
      let(:record) { Article.new id: 99999 }

      example 'finds it by type and id' do
        found = find_record record
        expect(found).to_not be
      end
    end
  end
end
