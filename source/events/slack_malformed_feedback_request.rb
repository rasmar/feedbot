# frozen_string_literal: true

module Events
  class SlackMalformedFeedbackRequest
    def initialize(channel)
      @channel = channel
    end

    def process
      Repos::Slack::MalformedFeedbackRequest.new(@channel).call
    end
  end
end
