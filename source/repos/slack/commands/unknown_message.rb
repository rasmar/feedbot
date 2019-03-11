# frozen_string_literal: true

module Repos
  module Slack
    class UnknownMessage < Base
      def initialize(channel)
        @channel = channel
      end

      private

      attr_reader :channel

      def payload
        {
          blocks: [
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: "I'm sorry but I can't understand you. What do you need? Try one of these:"
              }
            },
            {
              type: "divider"
            },
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: "*status `@username`* - displays a status of feedback request that was requested for specific user\n*list* - displays a list of feedback requests that you've received\n*request `@username` Message to be sent* - requests a feedback for specific user"
              }
            },
          ],
          channel: channel
        }.to_json
      end
    end
  end
end
