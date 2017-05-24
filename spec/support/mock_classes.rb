require 'json'

class Article
  attr_accessor :id

  def initialize opts
    @id = opts[:id]
  end
end

class People
  attr_accessor :id

  def initialize opts
    @id = opts[:id]
  end
end

JSON_BODY = JSON.parse(IO.read("spec/support/jsonapi.json"), symbolize_names: true)
