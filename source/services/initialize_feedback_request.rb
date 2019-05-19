# frozen_string_literal: true

module Services
  class InitializeFeedbackRequest
    def initialize(event)
      @event = event
    end

    def call
      return invalid_leadership_message unless validate_leadership

      # store_request
      send_confirmation_component
    end

    private

    attr_reader :event

    def invalid_leadership_message
      Repos::Slack::InvalidLeadershipMessage.new(event).call
    end

    def validate_leadership
      target_profile = Repos::Slack::ProfileGet.new(event).call
      leader = target_profile.dig("profile", "fields", Settings.slack_leader_label_id, "value")
      leader == event.requester
    end

    def store_request
      Repos::Database::StoreRequest.new(event).call
    end

    def send_confirmation_component
      Repos::Slack::ConfirmationComponent.new(event).call
    end

    def request_id
      SecureRandom.uuid
    end
  end
end
