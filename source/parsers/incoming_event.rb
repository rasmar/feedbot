# frozen_string_literal: true

module Parsers
  class IncomingEvent < OpenStruct
    def parse
      if slack_event? && user
        parse_slack_event
        slack_event
      elsif slack_event?
        Events::SlackBotMessage.new
      else
        Events::FormSubmit.new(attributes)
      end
    end

    private

    attr_reader :command, :requested_for, :message

    def attributes
      self.to_h
    end

    def user
      @user ||= event["user"]
    end

    def channel
      @channel ||= event["channel"]
    end

    def parse_slack_event
      @command, @requested_for, @message = event["text"]&.match(/([a-z]+) (@[^ ]+) (.*)/i)&.captures
    end

    def slack_event?
      !attributes[:team_id].nil?
    end

    def slack_event
      case type
      when "event_callback"
        slack_message_callback_event
      else
        Events::SlackFeedbackConfirmation.new(attributes)
      end
    end

    def slack_message_callback_event
      case command
      when "request"
        Events::SlackFeedbackRequest.new(channel, user, requested_for, message)
      when "list"
        Events::SlackFeedbackList.new(channel, user)
      when "status"
        Events::SlackStatusRequest.new(channel, user, requested_for)
      else
        Events::SlackUnknownMessage.new(channel, event)
      end
    end
  end
end
