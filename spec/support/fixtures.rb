# frozen_string_literal: true

module Fixtures
  extend self

  Dir["spec/support/fixtures/*.json"].each do |file|
    data = JSON.parse(File.read(file))
    filename = File.basename(file, ".json")
    define_method filename do
      data
    end
  end
end