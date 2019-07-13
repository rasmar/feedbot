# frozen_string_literal: true

module Repos
  module Slack
    class NoFeedbackRequest < Base
      def initialize(channel, target)
        @channel = channel
        @target = target
      end

      private

      attr_reader :channel, :target

      def action
        "chat.postMessage"
      end

      def payload
        {
          text: "\nIt seems that there is no ongoing feedback request for #{target.decorate}.\n" \
          "You can create one by a `request` command. If you need help type `help` :help:",
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
