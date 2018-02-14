require "rubygems"
require "rspec"
require "rspec-action/version"

module RSpec
  module Core
    module Hooks
      def action(&block)
        around do |ex|
          self.class.remove_previous_action &block
          self.class.before &block unless self.class.action_added?(&block)
          self.class.hooks.instance_variable_get(:@before_example_hooks)&.items_and_filters&.last&.instance_eval do
            def action_hook?; true; end
          end
          ex.run
        end
      end

      def remove_previous_action(&block)
        parent_groups.each do |parent|
          parent.hooks.instance_variable_get(:@before_example_hooks)&.items_and_filters&.delete_if {|hook| hook.respond_to?(:action_hook?)}
        end
      end

      def action_added?(&block)
        parent_groups_hooks = parent_groups.reverse.map { |parent| parent.hooks.instance_variable_get(:@before_example_hooks)&.items_and_filters }.flatten
        parent_groups_hooks.include? block
      end
    end
  end
end
