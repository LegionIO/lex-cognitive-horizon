# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module CognitiveHorizon
      module Actor
        class Adjust < Legion::Extensions::Actors::Every
          def runner_class
            Legion::Extensions::CognitiveHorizon::Runners::CognitiveHorizon
          end

          def runner_function
            'horizon_status'
          end

          def time
            60
          end

          def run_now?
            false
          end

          def use_runner?
            false
          end

          def check_subtask?
            false
          end

          def generate_task?
            false
          end
        end
      end
    end
  end
end
