# frozen_string_literal: true

module Repos
  module Database
    class ByRequester < Base
      def list_for_target(requester_id, target_id)
        client.query(
          table_name: table_name,
          index_name: index_name,
          expression_attribute_values: {
            ":v1" => requester_id,
            ":v2" => target_id,
            ":v3" => "active",
            ":v4" => "completed",
          },
          expression_attribute_names: {
            "#s" => "Status",
          },
          filter_expression: "#s IN (:v3, :v4)",
          key_condition_expression: "RequesterId = :v1 AND TargetId = :v2",
          select: "ALL_PROJECTED_ATTRIBUTES"
        )&.items
      end

      private

      def index_name
        "RequesterId-TargetId-index"
      end
    end
  end
end
