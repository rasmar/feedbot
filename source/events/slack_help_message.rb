# frozen_string_literal: true

module Events
  class SlackHelpMessage
    def initialize(channel)
      @channel = channel
    end

    def process
      Repos::Slack::Help.new(@channel).call
    end
  end
end
