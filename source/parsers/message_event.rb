# frozen_string_literal: true

module Parsers
  class MessageEvent
    def initialize(payload)
      @payload = payload
      @event = payload["event"]
    end

    def parse
      if slack_event? && user
        slack_message_callback_event
      elsif slack_event?
        Events::SlackBotMessage.new
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

    def status_user
      @status_user ||= text.match(/(?<=status <@)\w+(?=>)/).to_s
    end

    def slack_message_callback_event
      case command
      when "test_message"
        Events::SlackTestMessage.new(channel, payload)
      when "request"
        Parsers::SlackFeedbackRequest.new(user, channel, text).parse
      when "help"
        Events::SlackHelpMessage.new(channel)
      when "status"
        Events::SlackStatusMessage.new(user, channel, status_user)
      else
        Events::SlackUnknownMessage.new(channel)
      end
    end

    def text
      @text ||= event["text"]
    end
  end
end
