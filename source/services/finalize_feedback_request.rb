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
        permalink = get_permalink(ask_response[:channel], ask_response[:id])
        reminder_id = add_reminder(asked_id, permalink).dig("reminder", "id")
        store_ask_response(asked_id, ask_response, permalink, reminder_id)
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

    def get_permalink(channel, message_id)
      Repos::Slack::GetPermalink.new(channel, message_id).call["permalink"]
    end

    def add_reminder(asked_id, permalink)
      Repos::Slack::SetReminder.new(
        asked_id, DataObjects::Mention.new(request["TargetId"]), permalink, reminder_time
      ).call
    end

    def store_ask_response(asked_id, ask_response, permalink, reminder_id)
      Repos::Database::Base.new.put(
        "MessageId" => ask_response[:id],
        "RequesterId" => request["RequesterId"],
        "TargetId" => request["TargetId"],
        "AskedId" => asked_id,
        "Message" => request["Message"],
        "Status" => "active",
        "ActionId" => ask_response[:action_id],
        "Deadline" => deadline,
        "Permalink" => permalink,
        "ReminderId" => reminder_id
      )
    end

    def reminder_time
      (DateTime.strptime(deadline, "%Y-%m-%d").to_time - 14 * 60 * 60).to_i # Day before at 10:00
    end

    def mark_request_as_pending
      Repos::Database::ByMessage.new.mark_as_pending(request["MessageId"])
    end
  end
end
