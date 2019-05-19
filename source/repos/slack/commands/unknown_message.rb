# frozen_string_literal: true

module Repos
  module Slack
    class UnknownMessage < Base
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
            text: "*status `@username`* - displays a status of feedback request that was requested for specific user" \
            "\n*list* - displays a list of feedback requests that you've received" \
            "\n*request `@username` Message to be sent* - requests a feedback for specific user"
          }
        }
      end

      def info_section
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "I'm sorry but I can't understand you. How can I help you? Please, try one of these:"
          }
        }
      end

      def payload
        {
          blocks: [
            info_section,
            divider,
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
