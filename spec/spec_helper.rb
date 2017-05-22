require "bundler/setup"
require "jsonapi_expectations"
require "pry"
require_relative "./support/mock_classes"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.include JsonapiExpectations

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
