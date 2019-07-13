# frozen_string_literal: true

module Repos
  module Slack
    class ConfirmFeedbackRequest < Base
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
          text: "Thanks! The request was *created* and sent to users you've mentioned :rocket:\n\n" \
          "You can check the progress by typing:\n status #{target.decorate}",
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
