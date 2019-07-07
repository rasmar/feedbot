# frozen_string_literal: true

module Parsers
  class SlackFeedbackRequest
    def initialize(requester, channel, text)
      @requester = requester
      @channel = channel
      @text = text
    end

    def parse
      return malformed_feedback_request if invalid_request?

      Events::SlackFeedbackRequest.new(
        channel: channel,
        requester: requester,
        target: DataObjects::Mention.new(target),
        ask: ask.map { |user| DataObjects::Mention.new(user) },
        message: message
      )
    end

    private

    attr_reader :requester, :channel, :text

    def ask
      @ask ||= ask_block.scan(/(?<=<@)\w+(?=>)/)
    end

    def ask_block
      @ask_block ||= text.match(/(?<=ask:).+(?=(message:|for:))/).to_s
    end

    def invalid_request?
      ask.empty? || target.empty? || message.empty?
    end

    def malformed_feedback_request
      Events::SlackMalformedFeedbackRequest.new(channel)
    end

    def message
      @message ||= text.match(/(?<=message:).+\z/).to_s.lstrip
    end

    def target
      @target ||= text.match(/(?<=for:<@)\w+(?=>)/).to_s
    end
  end
end
