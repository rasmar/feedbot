# frozen_string_literal: true

module Events
  class SlackStatusMessage
    def initialize(user, channel, status_user)
      @user = user
      @channel = channel
      @status_user = status_user
    end

    def process
      Services::StatusMessage.new(@user, @channel, @status_user).call
    end
  end
end
