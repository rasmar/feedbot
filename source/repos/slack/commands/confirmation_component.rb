# frozen_string_literal: true

module Repos
  module Slack
    class ConfirmationComponent < Base
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
          blocks: [
            info,
            datepicker,
            divider,
            rejecter
          ],
          channel: event.channel
        }.to_json
      end

      def info
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "You are about to request feedback for #{event.target.decorate}\n\n" \
            "Message: #{event.message}\n\n" \
            "Send to:\n#{send_to}"
          }
        }
      end

      def datepicker
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "Now pick a date for the feedback deadline (this will send requests)."
          },
          accessory: {
            type: "datepicker",
            initial_date: Date.today.to_s,
            placeholder: {
              type: "plain_text",
              text: "Select a date",
              emoji: true
            }
          }
        }
      end

      def rejecter
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "If you changed your mind you may cancel the request (nothing was sent yet)."
          },
          accessory: {
            type: "button",
            text: {
              type: "plain_text",
              text: "Cancel",
              emoji: true
            },
            value: "cancel_request"
          }
        }
      end

      def request_method
        :post
      end

      def send_to
        receivers = ""
        event.ask.each do |user|
          receivers += "- #{user.decorate}\n"
        end
        receivers
      end

      def token
        Settings.slack_bot_token
      end
    end
  end
end
