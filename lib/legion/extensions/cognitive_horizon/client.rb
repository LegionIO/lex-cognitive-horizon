# frozen_string_literal: true

require 'legion/extensions/cognitive_horizon/helpers/constants'
require 'legion/extensions/cognitive_horizon/helpers/projection'
require 'legion/extensions/cognitive_horizon/helpers/horizon_engine'
require 'legion/extensions/cognitive_horizon/runners/cognitive_horizon'

module Legion
  module Extensions
    module CognitiveHorizon
      class Client
        include Runners::CognitiveHorizon

        def initialize(**)
          @horizon_engine = Helpers::HorizonEngine.new
        end

        private

        attr_reader :horizon_engine
      end
    end
  end
end
