require "bundler/setup"
require "jsonapi_expectations"
require "pry"
require_relative "./support/mock_classes"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.include JsonapiExpectations

  config.order = "random"
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
