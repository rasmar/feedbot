# frozen_string_literal: true

module Parsers
  class SlackFeedbackRequest
    def initialize(requester, channel, text)
      @requester = requester
      @channel = channel
      @text = text
    end

    def parse
      Events::SlackFeedbackRequest.new(
        channel:   channel,
        requester: requester,
        target:    target,
        mentions:  mentions,
        form:      form,
        message:   message
      )
    end

    private

    attr_reader :requester, :channel, :text

    def mentioned
      @mentioned ||= text.scan(/(?<=<@)([^>]+)(?=>)/)&.flatten
    end

    def mentions
      @mentions ||= mentioned[1..-1]
    end

    def message
      form_starting_point = /http/ =~ text
      @message ||= text[(form_starting_point + form.length + 2)..-1]
    end

    def target
      @target ||= mentioned.first
    end

    def form
      @form ||= text.match(/(?<=> <)http[^ >]+/).to_s
    end
  end
end
