# frozen_string_literal: true

module Services
  class CancelFeedbackRequest
    def initialize(request)
      @request = request
    end

    def call
      Repos::Database::ByMessage.new.delete(request["MessageId"])
    end

    private

    attr_reader :request
  end
end
