# frozen_string_literal: true

module Parsers
  class InteractiveEvent
    def initialize(payload)
      @payload = JSON.parse(URI.unescape(payload["body"].gsub(/\Apayload=/, "")))
    end

    def parse
      interactive_event
    end

    private

    attr_reader :payload

    def interactive_event
      Events::SlackInteractiveAction.new(
        message_id: payload.dig("message", "ts"),
        response_url: payload["response_url"],
        action: payload["actions"].first
      )
    end
  end
end
