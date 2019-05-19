# frozen_string_literal: true

module Repos
  module Slack
    class TestMessage < Base
      def initialize(channel, event)
        @channel = channel
        @event = event
      end

      private

      attr_reader :channel, :event

      def action
        "chat.postMessage"
      end

      def payload
        {
          blocks: [
            request_copy
          ],
          channel: channel
        }.to_json
      end

      def request_copy
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: JSON.generate(event)
          }
        }
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
