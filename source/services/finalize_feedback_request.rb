# frozen_string_literal: true

module Services
  class FinalizeFeedbackRequest
    def initialize(request, deadline)
      @request = request
      @deadline = deadline
    end

    def call
      mark_request_as_pending
      request["Ask"].each do |asked_id|
        ask_response = send_ask_request(asked_id)
        store_ask_response(asked_id, ask_response)
      end
    end

    private

    attr_reader :request, :deadline

    def send_ask_request(asked_id)
      Repos::Slack::AskFeedbackRequest.new(
        asked_id,
        DataObjects::Mention.new(request["RequesterId"]),
        DataObjects::Mention.new(request["TargetId"]),
        request["Message"],
        deadline
      ).call
    end

    def store_ask_response(asked_id, ask_response)
      Repos::Database::Base.new.put(
        "MessageId" => ask_response[:id],
        "RequesterId" => request["RequesterId"],
        "TargetId" => request["TargetId"],
        "AskedId" => asked_id,
        "Message" => request["Message"],
        "Status" => "active",
        "ActionId" => ask_response[:action_id],
        "Deadline" => deadline
      )
    end

    def mark_request_as_pending
      Repos::Database::ByMessage.new.mark_as_pending(request["MessageId"])
    end
  end
end

