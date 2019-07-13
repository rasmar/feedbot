# frozen_string_literal: true

module Events
  class SlackInteractiveAction < OpenStruct
    def process
      Services::InteractiveAction.new(self).call
    end
  end
end
