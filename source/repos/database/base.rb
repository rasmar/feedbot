# frozen_string_literal: true

module Repos
  module Database
    class Base
      def delete(key)
        client.delete_item(
          table_name: table_name,
          key: key
        )
      end

      def get(keys)
        client.get_item(table_name: table_name, key: keys)
      end

      def put(item)
        put_item = item.merge({ "TimeToExist" => ttl })
        client.put_item(table_name: table_name, item: put_item)
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

      def update(key, item)
        attribute_names, attribute_values, update_expression = update_expressions(item)

        client.update_item(
          table_name: table_name,
          expression_attribute_values: attribute_values,
          expression_attribute_names: attribute_names,
          update_expression: update_expression,
          key: key
        )
      end

      private

      def ttl
        (Time.now + 2592000).to_i # Month from now
      end

      def client
        @client ||= Aws::DynamoDB::Client.new
      end

      def table_name
        "Feedbot"
      end

      def update_expressions(item)
        name_key = "#a"
        val_key = ":a"
        attribute_names = {}
        attribute_values = {}
        update_expression = []

        item.each do |attr_name, attr_value|
          update_expression.push("#{name_key} = #{val_key}")
          attribute_names[name_key] = attr_name
          name_key = name_key.next
          attribute_values[val_key] = attr_value
          val_key = val_key.next
        end

        [attribute_names, attribute_values, "SET #{update_expression.join(', ')}"]
      end
    end
  end
end

require_relative "commands/by_message"
require_relative "commands/by_asked"
require_relative "commands/by_requester"
