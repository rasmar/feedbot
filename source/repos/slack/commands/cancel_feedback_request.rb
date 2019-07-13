# frozen_string_literal: true

module Repos
  module Slack
    class CancelFeedbackRequest < Base
      def initialize(response_url)
        @response_url = response_url
      end

      private

      attr_reader :response_url

      def uri
        URI(response_url)
      end

      def payload
        {
          text: "Okey! I've cancelled the request, nothing happened :ninja:",
          replace_original: "true",
        }.to_json
      end

      def request_method
        :post
      end

      def token
        Settings.slack_bot_token
      end
    end
  end
end
