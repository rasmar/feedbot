# frozen_string_literal: true

module DataObjects
  class Mention
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def decorate
      "<@#{user}>"
    end

    def to_s
      @user.to_s
    end
  end
end
