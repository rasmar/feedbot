# frozen_string_literal: true

module Services
  class StatusMessage
    def initialize(user, channel, status_user)
      @user = user
      @channel = channel
      @status_user = status_user
    end

    def call
      return no_request if ask_requests.empty?

      send_status_message
    end

    private

    attr_reader :user, :channel, :status_user

    def ask_requests
      @ask_requests ||= Repos::Database::ByRequester.new.list_for_target(user, status_user)
    end

    def no_request
      Repos::Slack::NoFeedbackRequest.new(channel, DataObjects::Mention.new(status_user)).call
    end

    def send_status_message
      ask_requests_formatted = ask_requests.map do |ask_request|
        {
          asked: DataObjects::Mention.new(ask_request["AskedId"]),
          status: ask_request["Status"] == "completed" ? ":white_check_mark:" : ":x:"
        }
      end
      Repos::Slack::StatusMessage.new(
        channel,
        DataObjects::Mention.new(status_user),
        ask_requests_formatted,
        ask_requests.first["Deadline"]
      ).call
    end
  end
end
