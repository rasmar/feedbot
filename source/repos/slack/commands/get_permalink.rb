# frozen_string_literal: true

module Repos
  module Slack
    class GetPermalink < Base
      def initialize(channel, message_id)
        @channel = channel
        @message_id = message_id
      end

      private

      attr_reader :channel, :message_id

      def action
        "chat.getPermalink"
      end

      def query
        "channel=#{channel}&message_ts=#{message_id}"
      end

      def request_method
        :get
      end

      def uri
        super.tap do |custom_uri|
          custom_uri.query = query
        end
      end

      def token
        Settings.slack_oauth_token
      end
    end
  end
end
