# frozen_string_literal: true

module Repos
  module Database
    class Base
      def get(keys)
        client.get_item(table_name: table_name, key: keys)
      end

      def put(item)
        client.put_item(table_name: table_name, item: item)
      end

      def query(primary_key_name, primary_key_value)
        client.query(
          table_name: table_name,
          expression_attribute_values: {
            ":v1" => primary_key_value
          },
          key_condition_expression: "#{primary_key_name} = :v1",
          select: "ALL_ATTRIBUTES"
        )
      end

      def update(keys, item)
        attribute_expression, update_expression = update_expressions(item)

        client.update(
          table_name: table_name,
          expression_attribute_values: attribute_expression,
          update_expression: update_expression,
          key: keys
        )
      end

      private

      def client
        @client ||= Aws::DynamoDB::Client.new
      end

      def table_name
        "Feedbot"
      end

      def update_expressions(item)
        key = ":a"
        attribute_expression = {}
        update_expression = []

        item.each do |attr_name, attr_value|
          update_expression.push("#{attr_name} = #{key}")
          attribute_expression[key] = attr_value
          key = key.next
        end

        [attribute_expression, "SET #{update_expression.join(', ')}"]
      end
    end
  end
end
