require 'spec_helper'
require 'json'

RSpec.describe JsonapiExpectations do
  let(:json_body) { JSON_BODY_ARRAY }

  example 'has a version number' do
    expect(JsonapiExpectations::VERSION).not_to be nil
  end

  describe 'expect_records_sorted_by' do
    context 'when records are sorted asc' do
      let(:json_body) { JSON_BODY_ASC }

      example 'expect sorted asc is good' do
        expect_records_sorted_by :title, direction: :asc
      end

      example 'expect sorted desc throws error' do
        expect{
          expect_records_sorted_by :title, direction: :desc
        }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
      end
    end

    context 'when records are sorted desc' do
      let(:json_body) { JSON_BODY_DESC }

      example 'expect sorted desc is good' do
        expect_records_sorted_by :title, direction: :desc
      end

      example 'expect sorted asc throws error' do
        expect{
          expect_records_sorted_by :title, direction: :asc
        }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
      end
    end
  end

  describe 'expect_attributes' do
    context 'array response' do
      context 'when present' do
        example 'can find attributes' do
          expect_attributes title: 'JSON API paints my bikeshed!',
                            published: '1'
          expect_attributes title: "It's Party Time!",
                            published: '1'
        end
      end

      context 'when absent' do
        example 'raises error if not found' do
          expect{
            expect_attributes title: 'foo'
          }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
        end

        example 'raises error on partial match' do
          expect{
            expect_attributes title: 'foo',
                              published: '1'
          }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
        end
      end
    end

    context 'single item response' do
      let(:json_body) { JSON_BODY_SINGLE }

      context 'when present' do
        example 'can find attributes' do
          expect_attributes title: 'JSON API paints my bikeshed!'
        end
      end

      context 'when absent' do
        example 'raises error if not found' do
          expect{
            expect_attributes title: 'foo'
          }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
        end
      end
    end
  end

  describe 'expect_attributes_absent' do
    context 'array response' do
      context 'when present' do
        example 'raises error if found' do
          expect{
            expect_attributes_absent :title
          }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
        end
      end
      context 'when absent' do
        example 'does not raise error' do
          expect_attributes_absent :hidden_field
        end
      end
    end
    context 'single item response' do
      let(:json_body) { JSON_BODY_SINGLE }

      context 'when present' do
        example 'raises error if found' do
          expect{
            expect_attributes_absent :title
          }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
        end
      end
      context 'when absent' do
        example 'does not raise error' do
          expect_attributes_absent :hidden_field
        end
      end
    end
  end

  describe 'expect_relationship' do
    context 'array response' do
      example 'find by links' do
        expect_relationship key: 'author',
                            link: 'http://example.com/articles/1/author'
      end

      example 'find by data' do
        expect_relationship key: 'author',
                            id: '9',
                            type: 'people'
      end

      example 'find included items' do
        expect_relationship key: 'author',
                            id: '9',
                            type: 'people',
                            included: true
      end

      example 'pass in array' do
        expect_relationship key: 'comments',
                            id: ['12', '5'],
                            included: true
      end

      example 'raises error if not found' do
        expect{
          expect_relationship key: 'widgets', id: '24'
        }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
      end
    end
  end

  describe 'expect_item_count' do
    example 'counts the elements inside data' do
      expect_item_count 2
    end

    example 'raises an error if not correct' do
      expect{
        expect_item_count 9999
      }.to raise_error RSpec::Expectations::ExpectationNotMetError
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
        }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
      end

      example 'can explicitly set type' do
        expect{
          expect_record record, type: 'articles'
        }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
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
        }.to raise_error JsonapiExpectations::Exceptions::ExpectationError
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
        expect(found[:attributes][:title]).to eq('JSON API paints my bikeshed!')
      end

      example 'can find included objects' do
        found = find_record included, type: 'people', included: true
        expect(found).to be
        expect(found[:attributes][:"first-name"]).to eq('Dan')
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
