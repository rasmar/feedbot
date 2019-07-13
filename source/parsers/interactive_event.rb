# frozen_string_literal: true

module Parsers
  class InteractiveEvent
    def initialize(payload)
      @event = JSON.parse(URI.unescape(payload["body"].gsub(/\Apayload=/, "")))
    end

    def parse
      true
    end

    private

    attr_reader :event
  end
end
