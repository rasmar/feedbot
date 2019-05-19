# frozen_string_literal: true

module Events
  class SlackFeedbackRequest < OpenStruct
    def process
      Services::InitializeFeedbackRequest.new(self).call
    end
  end
end
