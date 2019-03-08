# frozen_string_literal: true

require "json"

require_relative "responses/project_list"

SLACK_CONFIG = {
  access_token: ENV["SLACK_ACCESS_TOKEN"]
}
