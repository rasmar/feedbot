# frozen_string_literal: true

module Events
  class SlackUnknownMessage
    def initialize(channel)
      @channel = channel
    end

    def process
      Repos::Slack::UnknownMessage.new(@channel).call
    end
  end
end
