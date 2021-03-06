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

      def info_section
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "I'm sorry but I can't understand you. If you are lost please try typing `help`."
          }
        }
      end

      def payload
        {
          blocks: [
            info_section,
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
