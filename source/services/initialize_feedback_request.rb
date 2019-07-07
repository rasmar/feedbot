# frozen_string_literal: true

module Services
  class InitializeFeedbackRequest
    def initialize(event)
      @event = event
    end

    def call
      return false unless Services::Leadership.new.validate_leadership(event.channel, event.requester, event.target)

      send_confirmation_component
    end

    private

    attr_reader :event

    def send_confirmation_component
      Repos::Slack::ConfirmationComponent.new(event).call
    end
  end
end
