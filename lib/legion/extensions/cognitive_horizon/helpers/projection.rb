# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveHorizon
      module Helpers
        class Projection
          attr_reader :id, :description, :domain, :horizon_distance, :confidence, :construal_level, :created_at

          def initialize(description:, domain: :general, horizon_distance: Constants::DEFAULT_HORIZON,
                         confidence: 1.0, construal_level: nil)
            @id               = SecureRandom.uuid
            @description      = description
            @domain           = domain
            @horizon_distance = horizon_distance.clamp(0.0, 1.0)
            @confidence       = confidence.clamp(0.0, 1.0)
            @construal_level  = construal_level || derive_construal_level(@horizon_distance)
            @created_at       = Time.now.utc
          end

          def concrete?
            @horizon_distance <= 0.3
          end

          def abstract?
            @horizon_distance >= 0.7
          end

          def to_h
            {
              id:               @id,
              description:      @description,
              domain:           @domain,
              horizon_distance: @horizon_distance.round(10),
              confidence:       @confidence.round(10),
              construal_level:  @construal_level,
              concrete:         concrete?,
              abstract:         abstract?,
              created_at:       @created_at
            }
          end

          private

          def derive_construal_level(distance)
            entry = Constants::CONSTRUAL_LABELS.find { |e| e[:range].cover?(distance) }
            entry ? entry[:label] : :balanced
          end
        end
      end
    end
  end
end
