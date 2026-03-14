# frozen_string_literal: true

require 'legion/extensions/cognitive_horizon/version'
require 'legion/extensions/cognitive_horizon/helpers/constants'
require 'legion/extensions/cognitive_horizon/helpers/projection'
require 'legion/extensions/cognitive_horizon/helpers/horizon_engine'
require 'legion/extensions/cognitive_horizon/runners/cognitive_horizon'

module Legion
  module Extensions
    module CognitiveHorizon
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
