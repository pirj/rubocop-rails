# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Checks for comparisons of time with the current time.
      # Use `past?` and `future?` instead.
      #
      # Comparisons that involve arithmetic, such as `time + 1.day < Time.current`, are ignored,
      # as moving the duration across the comparison is not exact for calendar durations.
      # Non-strict comparisons (`<=`, `>=`), and comparisons with `Date.current` are ignored, too.
      #
      # @example
      #   # bad
      #   grand_opening_at < Time.current
      #   Time.zone.now > grand_opening_at
      #   grand_opening_at.before?(Time.current)
      #   public_release_at > Time.current
      #   public_release_at.after?(Time.current)
      #   Time.current.before?(public_release_at)
      #
      #   # good
      #   grand_opening_at.past?
      #   public_release_at.future?
      #
      class TimeComparison < Base
        extend AutoCorrector

        MSG = 'Use `%<prefer>s` instead.'

        RESTRICT_ON_SEND = %i[< > before? after?].freeze

        EARLIER_METHODS = %i[< before?].freeze

        # @!method current_time?(node)
        def_node_matcher :current_time?, <<~PATTERN
          {
            (send (const {nil? cbase} :Time) :current)
            (send (send (const {nil? cbase} :Time) :zone) :now)
          }
        PATTERN

        def on_send(node)
          return unless node.arguments.one?

          time, current_time_first = compared_time(node)
          return unless time
          return if arithmetic?(time)
          return if safe_navigation_lost?(node, time)

          prefer = "#{time.source}#{dot(node, time)}#{predicate(node, current_time_first)}"

          add_offense(node, message: format(MSG, prefer: prefer)) do |corrector|
            corrector.replace(node, prefer)
          end
        end
        alias on_csend on_send

        private

        def compared_time(node)
          if current_time?(node.first_argument)
            [node.receiver, false]
          elsif current_time?(node.receiver)
            [node.first_argument, true]
          end
        end

        def arithmetic?(node)
          node = node.children.first while node.begin_type? && node.children.one?

          node.send_type? && node.arithmetic_operation?
        end

        # `time&.before?(Time.current)` keeps its safe navigation as `time&.past?`,
        # while `time&.at < Time.current` raises on `nil`, and `time&.at.past?` returns `nil`.
        def safe_navigation_lost?(node, time)
          return false if !node.operator_method? && time.equal?(node.receiver)

          safe_navigation?(time)
        end

        def safe_navigation?(node)
          while node
            return true if node.csend_type?

            node = node.call_type? ? node.receiver : nil
          end

          false
        end

        def dot(node, time)
          node.csend_type? && time.equal?(node.receiver) ? '&.' : '.'
        end

        def predicate(node, current_time_first)
          earlier = EARLIER_METHODS.include?(node.method_name)

          earlier ^ current_time_first ? 'past?' : 'future?'
        end
      end
    end
  end
end
