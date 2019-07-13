# frozen_string_literal: true

module Repos
  module Slack
    class Base
      def call
        response = JSON.parse(send(request_method).body)
        return_specific? ? specific_response(response) : response
      end

      private

      def action_id_extractor(response, type, value = nil)
        block = response.dig("message", "blocks").detect do |block|
          block.key?("accessory") && block["accessory"]["type"] == type && block["accessory"]["value"] == value
        end
        return nil unless block.is_a?(Hash)

        block["accessory"]["action_id"]
      end

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

      def message_timestamp(response)
        response["ts"]
      end

      def payload
        raise NotImplemented
      end

      def post
        HTTParty.post(uri.to_s, body: payload, headers: headers)
      end

      def request_id
        @request_id ||= SecureRandom.uuid
      end

      def request_method
        raise NotImplemented
      end

      def return_specific?
        false
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
require_relative "commands/malformed_feedback_request"
require_relative "commands/help"
require_relative "commands/cancel_feedback_request"
require_relative "commands/confirm_feedback_request"
require_relative "commands/ask_feedback_request"
require_relative "commands/complete_feedback_request"
