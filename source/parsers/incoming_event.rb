# frozen_string_literal: true

module Parsers
  class IncomingEvent
    def initialize(payload)
      @payload = payload
      @event = payload["event"]
    end

    def parse
      if slack_event? && user
        slack_event
      elsif slack_event?
        Events::SlackBotMessage.new
      # else
      #   Events::FormSubmit.new
      end
    end

    private

    attr_reader :payload, :event

    def user
      @user ||= event["user"]
    end

    def channel
      @channel ||= event["channel"]
    end

    def command
      @command ||= text.match(/^[^ ]+/).to_s.downcase
    end

    def slack_event?
      payload["team_id"] || payload["team"]
    end

    def slack_event
      case payload["type"]
      when "event_callback"
        slack_message_callback_event
      # when "block_actions"
      #   Events::SlackFeedbackConfirmation.new
      end
    end

    def slack_message_callback_event
      case command
      when "test_message"
        Events::SlackTestMessage.new(channel, payload)
      when "request"
        Parsers::SlackFeedbackRequest.new(user, channel, text).parse
      # when "list"
      #   Events::SlackFeedbackList.new(channel, user)
      # when "status"
      #   Events::SlackStatusRequest.new(channel, user, requested_for)
      else
        Events::SlackUnknownMessage.new(channel)
      end
    end

    def text
      @text ||= event["text"]
    end
  end
end
