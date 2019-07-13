# frozen_string_literal: true

module Repos
  module Slack
    class StatusMessage < Base
      def initialize(channel, status_user, ask_requests, deadline)
        @channel = channel
        @status_user = status_user
        @ask_requests = ask_requests
        @deadline = deadline
      end

      private

      attr_reader :channel, :status_user, :ask_requests, :message, :deadline

      def action
        "chat.postMessage"
      end

      def payload
        {
          blocks: [
            info,
          ],
          channel: channel
        }.to_json
      end

      def info
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "\n:point_down: current feedback request status for #{status_user.decorate} :point_down:\n\n" \
            "Deadline: #{deadline}\n" \
            "#{ask_requests_formatted}",
          },
        }
      end

      def request_method
        :post
      end

      def ask_requests_formatted
        formatted = ""
        ask_requests.each do |ask_request|
          formatted += "- #{ask_request[:asked].decorate} #{ask_request[:status]}\n"
        end
        formatted
      end

      def token
        Settings.slack_bot_token
      end
    end
  end
end
