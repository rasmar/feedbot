# frozen_string_literal: true

module Repos
  module Slack
    class AskFeedbackRequest < Base
      def initialize(asked_id, requester, target, message, deadline)
        @asked_id = asked_id
        @requester = requester
        @target = target
        @message = message
        @deadline = deadline
      end

      private

      attr_reader :asked_id, :requester, :target, :message, :deadline

      def action
        "chat.postMessage"
      end

      def payload
        {
          blocks: [
            info,
            confirmer
          ],
          channel: asked_id
        }.to_json
      end

      def info
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "Hello! #{requester.decorate} has requested your feedback for #{target.decorate}.\n\n" \
            "Deadline: #{deadline}\n" \
            "Message: #{message}\n"
          }
        }
      end

      def confirmer
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "Once you are done, please confirm it by clicking this button :point_right:"
          },
          accessory: {
            type: "button",
            text: {
              type: "plain_text",
              text: "Confirm",
              emoji: true
            },
            value: "confirm_request"
          }
        }
      end

      def return_specific?
        true
      end

      def request_method
        :post
      end

      def specific_response(response)
        {
          id: message_timestamp(response),
          action_id: action_id_extractor(response, "button", "confirm_request")
        }
      end


      def token
        Settings.slack_bot_token
      end
    end
  end
end
