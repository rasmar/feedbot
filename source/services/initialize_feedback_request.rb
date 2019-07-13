# frozen_string_literal: true

module Services
  class InitializeFeedbackRequest
    def initialize(event)
      @event = event
    end

    def call
      return false unless Services::Leadership.new.validate_leadership(event.channel, event.requester, event.target)

      store_response(send_confirmation_component)
    end

    private

    attr_reader :event

    def send_confirmation_component
      Repos::Slack::ConfirmationComponent.new(event).call
    end
    
    def store_response(confirmation_response)
      Repos::Database::Base.new.put(
        "RequestId" => confirmation_response[:id],
        "Requester" => event.requester.to_s,
        "Target" => event.target.to_s,
        "Ask" => event.ask.map(&:to_s),
        "Message" => event.message,
        "DatepickerActionId" => confirmation_response[:datepicker_action_id],
        "CancelButtonActionId" => confirmation_response[:cancel_button_action_id]
      )
    end
  end
end
