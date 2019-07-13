# frozen_string_literal: true

module Repos
  module Database
    class ByAsked < Base
      def list(asked_id, status = "active")
        client.query(
          table_name: table_name,
          index_name: index_name,
          expression_attribute_values: {
            ":v1" => asked_id,
            ":v2" => status,
          },
          expression_attribute_names: {
            "#k1" => "Status"
          },
          key_condition_expression: "AskedId = :v1 AND #k1 = :v2",
          select: "ALL_ATTRIBUTES"
        ).items
      end

      private

      def index_name
        "AskedId-Status-index"
      end
    end
  end
end
