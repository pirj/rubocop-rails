# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Enforces the use of `all_(day|week|month|quarter|year)` over
      # `beginning_of_(day|week|month|quarter|year)..end_of_(day|week|month|quarter|year)`
      # to get the range of date/time.
      #
      # @example
      #
      #   # bad
      #   date.beginning_of_day..date.end_of_day
      #   date.beginning_of_week..date.end_of_week
      #   date.beginning_of_month..date.end_of_month
      #   date.beginning_of_quarter..date.end_of_quarter
      #   date.beginning_of_year..date.end_of_year
      #
      #   # good
      #   date.all_day
      #   date.all_week
      #   date.all_month
      #   date.all_quarter
      #   date.all_year
      #
      class DateTimeRange < Base
        extend AutoCorrector

        MSG = 'Use `%<replacement>s` instead.'

        END_METHODS = {
          beginning_of_day: :end_of_day,
          beginning_of_week: :end_of_week,
          beginning_of_month: :end_of_month,
          beginning_of_quarter: :end_of_quarter,
          beginning_of_year: :end_of_year
        }.freeze

        PREFER_METHODS = {
          beginning_of_day: :all_day,
          beginning_of_week: :all_week,
          beginning_of_month: :all_month,
          beginning_of_quarter: :all_quarter,
          beginning_of_year: :all_year
        }.freeze

        def on_irange(node)
          range_begin = node.begin
          range_end = node.end
          return if allow?(range_begin, range_end)

          replacement = replacement(range_begin)

          if range_begin.method?(:beginning_of_week) && range_begin.arguments.one?
            return unless same_argument?(range_begin, range_end)

            replacement << "(#{range_begin.first_argument.source})"
          elsif any_arguments?(range_begin, range_end)
            return
          end

          register_offense(node, replacement)
        end

        private

        def allow?(range_begin, range_end)
          !range_begin&.send_type? || !range_end&.send_type? ||
            range_begin.receiver.source != range_end.receiver.source ||
            END_METHODS[range_begin.method_name] != range_end.method_name
        end

        def same_argument?(range_begin, range_end)
          range_begin.first_argument.source == range_end.first_argument.source
        end

        def replacement(range_begin)
          +"#{range_begin.receiver.source}.#{PREFER_METHODS[range_begin.method_name]}"
        end

        def any_arguments?(range_begin, range_end)
          range_begin.arguments.any? || range_end.arguments.any?
        end

        def register_offense(node, replacement)
          message = format(MSG, replacement: replacement)

          add_offense(node, message: message) do |corrector|
            corrector.replace(node, replacement)
          end
        end
      end
    end
  end
end
