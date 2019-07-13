# frozen_string_literal: true

module Repos
  module Slack
    class Help < Base
      def initialize(channel)
        @channel = channel
      end

      private

      attr_reader :channel

      def action
        "chat.postMessage"
      end

      def commands_section
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "*Request a feedback for specific user:*\n"\
            "request for: @user ask: @user1 @user2 message: message to be sent\n\n" \
            "*Check feedback request status:*\n" \
            "status @user"
          }
        }
      end

      def payload
        {
          blocks: [
            commands_section
          ],
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
