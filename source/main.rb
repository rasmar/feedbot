# frozen_string_literal: true

require_relative "config/environment"

def interact(event:, context:)
	return { statusCode: 200, challenge: event["challenge"]} if event["challenge"] 
	user = event["event"]["user"]
	# event = Parsers::IncomingEvent.new(event).parse
	return { statusCode: 200 } unless user 
  Net::HTTP.post URI('https://slack.com/api/chat.postMessage'),
              { text: "Hello! #{event}", channel: event["event"]["channel"] }.to_json,
              "Content-Type" => "application/json", "Authorization" => "Bearer #{Settings.slack_token}"
	{ statusCode: 200 }
end
