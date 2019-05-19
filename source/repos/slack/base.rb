# frozen_string_literal: true

module Repos
  module Slack
    class Base
      def call
        JSON.parse(send(request_method).body)
      end

      private

      def action
        raise NotImplemented
      end

      def base_uri
        "https://slack.com/api/"
      end

      def divider
        {
          type: "divider"
        }
      end

      def get
        HTTParty.get(uri.to_s, headers: headers)
      end

      def headers
        {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{token}"
        }
      end

      def payload
        raise NotImplemented
      end

      def post
        HTTParty.post(uri.to_s, body: payload, headers: headers)
      end

      def request_method
        raise NotImplemented
      end

      def uri
        URI(base_uri + action)
      end

      def token
        raise NotImplemented
      end
    end
  end
end

require_relative "commands/unknown_message"
require_relative "commands/test_message"
require_relative "commands/profile_get"
require_relative "commands/invalid_leadership_message"
require_relative "commands/confirmation_component"
