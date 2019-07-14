# frozen_string_literal: true

module Services
  class CompleteFeedbackRequest
    def initialize(request)
      @request = request
    end

    def call
      mark_request_as_completed
      delete_reminder
    end

    private

    attr_reader :request

    def delete_reminder
      Repos::Slack::DeleteReminder.new(request["ReminderId"]).call
    end

    def mark_request_as_completed
      Repos::Database::ByMessage.new.mark_as_completed(request["MessageId"])
    end
  end
end
