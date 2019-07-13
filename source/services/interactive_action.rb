# frozen_string_literal: true

module Services
  class InteractiveAction
    def initialize(event)
      @event = event
    end

    def call
      case event.action["type"]
      when "datepicker"
        confirm_request
      when "button"
        if request["CancelId"] == event.action["action_id"]
          cancel_request
        else
          true
        end
      end
    end

    private

    attr_reader :event

    def cancel_request
      Services::CancelFeedbackRequest.new(request).call
      Repos::Slack::CancelFeedbackRequest.new(event.response_url).call
    end

    def confirm_request
      Services::FinalizeFeedbackRequest.new(request, event.action["selected_date"]).call
      Repos::Slack::ConfirmFeedbackRequest.new(
        event.response_url,
        DataObjects::Mention.new(request["TargetId"])
      ).call
    end

    def request
      @request ||= Repos::Database::ByMessage.new.get(event.message_id)
    end
  end
end
