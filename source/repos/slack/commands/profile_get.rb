# frozen_string_literal: true

module Repos
  module Slack
    class ProfileGet < Base
      def initialize(user)
        @user = user.to_s
      end

      private

      attr_reader :user

      def action
        "users.profile.get"
      end

      def query
        "user=#{user}"
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
