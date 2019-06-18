# frozen_string_literal: true

require_relative "../config/environment"

module FeedBot
  module Handler
    module SlackComponent
      extend self

      def handle(event:, context:)
        event = Parsers::InteractiveEvent.new(event).parse
        event.process
        { statusCode: 200 }
      end
    end
  end
end
