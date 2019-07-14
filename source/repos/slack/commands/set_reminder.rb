# frozen_string_literal: true

module Repos
  module Slack
    class SetReminder < Base
      def initialize(asked_id, target, permalink, reminder_time)
        @asked_id = asked_id
        @target = target
        @permalink = permalink
        @reminder_time = reminder_time
      end

      private

      attr_reader :asked_id, :target, :permalink, :reminder_time

      def action
        "reminders.add"
      end

      def payload
        {
          text: "Hey! Please do not forget to give feedback for #{target.decorate}. " \
          "The deadline is for tomorrow :alarm_clock:\n" \
          "If you've lost the message, here you go: \n\n#{permalink}\n\n" \
          "Remember to always confirm that you've finished writing the feedback, " \
          "so I won't interrupt you anymore :face_with_hand_over_mouth:",
          user: asked_id,
          time: reminder_time
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
