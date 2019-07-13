# frozen_string_literal: true

module Repos
  module Slack
    class CompleteFeedbackRequest < Base
      def initialize(response_url, target)
        @response_url = response_url
        @target = target
      end

      private

      attr_reader :response_url, :target

      def uri
        URI(response_url)
      end

      def payload
        {
          text: "Thanks for spending some time on giving feedback for #{target.decorate}! :muscle:\n\n" \
          "Feedbacks are crucial part of our company culture, thank you for being part of it :ng-love:",
          replace_original: "true",
        }.to_json
      end

      def request_method
        :post
      end

      def token
        Settings.slack_bot_token
      end
    end
  end
end
