# frozen_string_literal: true

require_relative "environment"

def request_feedback(event:, context:)
	{
		statusCode: 200,
		body: Responses::ProjectList.generate_list(1)
	}
end
