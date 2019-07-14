# frozen_string_literal: true

module Repos
  module Slack
    class DeleteReminder < Base
      def initialize(reminder_id)
        @reminder_id = reminder_id
      end

      private

      attr_reader :reminder_id

      def action
        "reminders.delete"
      end

      def payload
        {
          reminder: reminder_id
        }.to_json
      end

      def request_method
        :post
      end

      def token
        Settings.slack_oauth_token
      end
    end
  end
end
