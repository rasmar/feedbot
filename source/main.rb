# frozen_string_literal: true

require_relative "config/environment"

def interact(event:, context:)
	event = Parsers::IncomingEvent.new(event).parse
	{
		statusCode: 200,
		body: Responses::ProjectList.generate_list(1)
	}
end
