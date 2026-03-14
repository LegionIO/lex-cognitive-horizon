# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveHorizon
      module Helpers
        module Constants
          # Projection store limit
          MAX_PROJECTIONS = 200

          # Horizon values (0.0 = immediate, 1.0 = strategic)
          DEFAULT_HORIZON    = 0.5
          HORIZON_EXPAND     = 0.08
          HORIZON_CONTRACT   = 0.1
          MIN_HORIZON        = 0.1
          MAX_HORIZON        = 1.0

          # Stress adds additional contraction on top of HORIZON_CONTRACT
          STRESS_CONTRACTION = 0.15

          # Ordered horizon levels (near -> far)
          HORIZON_LEVELS = %i[immediate near_term medium_term long_term strategic].freeze

          # Construal labels keyed by range (horizon distance 0..1)
          CONSTRUAL_LABELS = [
            { range: (0.0...0.2),  label: :concrete },
            { range: (0.2...0.4),  label: :detailed },
            { range: (0.4...0.6),  label: :balanced },
            { range: (0.6...0.8),  label: :schematic },
            { range: (0.8..1.0),   label: :abstract }
          ].freeze

          # Confidence erodes by this much per step away from current horizon
          CONFIDENCE_DECAY_PER_STEP = 0.1
        end
      end
    end
  end
end
