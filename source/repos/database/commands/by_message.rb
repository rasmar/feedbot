# frozen_string_literal: true

module Repos
  module Database
    class ByMessage < Base
      def delete(message_id)
        super("MessageId" => message_id)
      end

      def get(message_id)
        super("MessageId" => message_id).item
      end

      def update(message_id, item)
        super({ "MessageId" => message_id }, item)
      end

      def mark_as_completed(message_id)
        update(message_id, { "Status" => "completed" })
      end

      def mark_as_pending(message_id)
        update(message_id, { "Status" => "pending" })
      end
    end
  end
end
