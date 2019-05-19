# frozen_string_literal: true

module Repos
  module Slack
    class InvalidLeadershipMessage < Base
      def initialize(event)
        @event = event
      end

      private

      attr_reader :event

      def action
        "chat.postMessage"
      end

      def payload
        {
          text: "I'm really sorry but <@#{event.target}> doesn't seem to have set you as a leader in the profile. " \
          "I can't process your request unless your name is in the 'My Leader' field in target's profile.",
          channel: event.channel
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
