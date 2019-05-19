# frozen_string_literal: true

module Services
  class FinalizeFeedbackRequest
    def initialize(requester, target, mentions, form, message)
      @requester = requester
      @target = target
      @mentions = mentions
      @form = form
      @message = message
    end

    def call
      request = Repos::Database::FetchRequest(request_id).new.call
      mentions.each do |mention|
        Repos::Slack::ReqestMessage.new(mention, message, date).call
        Repos::Slack::CreateReminder.new(mention, target, date).call
      end
    end

    private

    attr_reader :requester, :target, :mentions, :form, :message
  end
end
