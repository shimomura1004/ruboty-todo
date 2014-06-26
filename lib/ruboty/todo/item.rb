module Ruboty
  module Todo
    class Item
      attr_reader :attributes

      def initialize(attributes)
        @attributes = attributes.stringify_keys
      end

      def to_hash
        attributes
      end

      def default_description
        if complete == "complete"
          %<[X] %5s  %s> % [id, body]
        else
          %<[_] %5s  %s> % [id, body]
        end
      end

      def as_style_description
        if complete == "complete"
          %<- %5s  %s @done> % [id, body]
        else
          %<- %5s  %s > % [id, body]
        end
      end

      def id
        attributes["id"]
      end

      def body
        attributes["body"]
      end

      def from
        attributes["from"]
      end

      def to
        attributes["to"]
      end

      def complete
        attributes["complete"]
      end
    end
  end
end
