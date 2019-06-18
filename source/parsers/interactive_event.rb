# frozen_string_literal: true

module Parsers
  class InteractiveEvent
    def initialize(payload)
      @payload = payload
      @event = payload["event"]
    end

    def parse
      true
    end

    private

    attr_reader :payload, :event
  end
end
