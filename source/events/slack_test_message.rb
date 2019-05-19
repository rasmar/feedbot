# frozen_string_literal: true

module Events
  class SlackTestMessage
    def initialize(channel, event)
      @channel = channel
      @event = event
    end

    def process
      Repos::Slack::TestMessage.new(@channel, @event).call
    end
  end
end
