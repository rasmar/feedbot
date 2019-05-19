# frozen_string_literal: true

module Repos
  module Slack
    class ProfileGet < Base
      def initialize(event)
        @event = event
      end

      private

      attr_reader :event

      def action
        "users.profile.get"
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

      def query
        "user=#{event.target}"
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
