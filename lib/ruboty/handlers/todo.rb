module Ruboty
  module Handlers
    class Todo < Base
      NAMESPACE = "todo"

      env :TODO_RESPONSE_STYLE, "asakusasatellite: Use AsakusaSatellite style", optional: true

      on(/add todo (?<body>.+)/, name: "add", description: "Add a new todo item")
      on(/delete todo (?<id>\d+)/, name: "delete", description: "Delete a todo item")
      on(/mark todo (?<id>\d+) as complete/, name: "mark_as_complete", description: "Mark the task as complete")
      on(/mark todo (?<id>\d+) as incomplete/, name: "mark_as_incomplete", description: "Mark the task as incomplete")
      on(/list todos\z/, name: "list", description: "List all todo items")

      attr_writer :items

      def initialize(*args)
        super
        remember
      end

      def add(message)
        item = create(message)
        message.reply("Todo #{item.id} added")
        list(message)
      end

      def delete(message)
        id = message[:id].to_i
        if items.has_key?(id)
          items.delete(id)
          message.reply("Todo #{id} deleted")
          list(message)
        else
          message.reply("Todo #{id} does not exist")
          list(message)
        end
      end

      def list(message)
        message.reply(summary, code: true)
      end

      def mark_as_complete(message)
        id = message[:id].to_i
        if items.has_key?(id)
          items[id]["complete"] = "complete"
          list(message)
        else
          message.reply("Todo #{id} does not exist")
        end
      end

      def mark_as_incomplete(message)
        id = message[:id].to_i
        if items.has_key?(id)
          items[id]["complete"] = "incomplete"
          list(message)
        else
          message.reply("Todo #{id} does not exist")
        end
      end

      private

      def remember
        items.each do |id, attributes|
          item = Ruboty::Todo::Item.new(attributes)
        end
      end

      def items
        robot.brain.data[NAMESPACE] ||= {}
      end

      def create(message)
        item = Ruboty::Todo::Item.new(
          message.original.except(:robot).merge(
            body: message[:body],
            id: generate_id,
          ),
        )
        items[item.id] = item.to_hash
        item
      end

      def summary
        if items.empty?
          empty_message
        else
          item_descriptions
        end
      end

      def empty_message
        "Todo not found"
      end

      def item_descriptions
        if as_style?
          as_style_descriptions
        else
          defualt_descriptions
        end
      end

      def defualt_descriptions
        items.values.map do |attributes|
          Ruboty::Todo::Item.new(attributes).default_description
        end.join("\n")
      end

      def as_style_descriptions
        "taskpaper::\n" + items.values.map do |attributes|
          Ruboty::Todo::Item.new(attributes).as_style_description
        end.join("\n")
      end

      def generate_id
        loop do
          id = rand(10000)
          break id unless items.has_key?(id)
        end
      end

      def as_style?
        ENV['TODO_RESPONSE_STYLE'] == 'asakusasatellite'
      end
    end
  end
end
