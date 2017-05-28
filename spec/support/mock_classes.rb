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

# THIS IS FINE
JSON_BODY_SINGLE = JSON.parse(IO.read("spec/support/jsonapi-single.json"), symbolize_names: true)
JSON_BODY_ARRAY = JSON.parse(IO.read("spec/support/jsonapi-array.json"), symbolize_names: true)
