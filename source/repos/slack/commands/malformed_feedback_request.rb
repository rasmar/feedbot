# frozen_string_literal: true

module Repos
  module Slack
    class MalformedFeedbackRequest < Base
      def initialize(channel)
        @channel = channel
      end

      private

      attr_reader :channel

      def action
        "chat.postMessage"
      end

      def payload
        {
          text: "\nI'm really sorry but your message was malformed. Proper format for a request:\n\n" \
          "request for: @user ask: @user2 @user3 @user4 message: Feedback Message \n\n" \
          "Please try again! :fingers_crossed: :slightly_smiling_face:",
          channel: channel
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
