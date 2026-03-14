# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveHorizon
      module Helpers
        class HorizonEngine
          attr_reader :projections, :current_horizon, :stress_level

          def initialize(initial_horizon: Constants::DEFAULT_HORIZON)
            @projections     = []
            @current_horizon = initial_horizon.clamp(Constants::MIN_HORIZON, Constants::MAX_HORIZON)
            @stress_level    = 0.0
          end

          def add_projection(description:, domain: :general, horizon_distance: nil, confidence: 1.0)
            dist = horizon_distance || @current_horizon
            proj = Projection.new(
              description:      description,
              domain:           domain,
              horizon_distance: dist,
              confidence:       confidence
            )
            @projections << proj
            @projections = @projections.last(Constants::MAX_PROJECTIONS) if @projections.size > Constants::MAX_PROJECTIONS
            proj
          end

          def expand_horizon!(amount: Constants::HORIZON_EXPAND)
            @current_horizon = (@current_horizon + amount).clamp(Constants::MIN_HORIZON, Constants::MAX_HORIZON)
            @current_horizon
          end

          def contract_horizon!(amount: Constants::HORIZON_CONTRACT)
            @current_horizon = (@current_horizon - amount).clamp(Constants::MIN_HORIZON, Constants::MAX_HORIZON)
            @current_horizon
          end

          def apply_stress!(level)
            @stress_level = level.clamp(0.0, 1.0)
            @current_horizon = (@current_horizon - (@stress_level * Constants::STRESS_CONTRACTION))
                               .clamp(Constants::MIN_HORIZON, Constants::MAX_HORIZON)
            @current_horizon
          end

          def relieve_stress!(amount: 0.1)
            @stress_level = (@stress_level - amount).clamp(0.0, 1.0)
          end

          def effective_horizon
            (@current_horizon - (@stress_level * Constants::STRESS_CONTRACTION))
              .clamp(Constants::MIN_HORIZON, Constants::MAX_HORIZON)
          end

          def projections_within_horizon
            eh = effective_horizon
            @projections.select { |p| p.horizon_distance <= eh }
          end

          def beyond_horizon_projections
            eh = effective_horizon
            @projections.select { |p| p.horizon_distance > eh }
          end

          def nearest_projections(num: 5)
            @projections.sort_by(&:horizon_distance).first(num)
          end

          def farthest_projections(num: 5)
            @projections.sort_by(&:horizon_distance).last(num).reverse
          end

          def construal_label
            dist = effective_horizon
            entry = Constants::CONSTRUAL_LABELS.find { |e| e[:range].cover?(dist) }
            entry ? entry[:label] : :balanced
          end

          def horizon_report
            {
              current_horizon:   @current_horizon.round(10),
              stress_level:      @stress_level.round(10),
              effective_horizon: effective_horizon.round(10),
              construal_label:   construal_label,
              horizon_level:     horizon_level,
              total_projections: @projections.size,
              within_horizon:    projections_within_horizon.size,
              beyond_horizon:    beyond_horizon_projections.size
            }
          end

          def to_h
            horizon_report.merge(projections: @projections.map(&:to_h))
          end

          private

          def horizon_level
            idx = (effective_horizon * (Constants::HORIZON_LEVELS.size - 1)).round
            Constants::HORIZON_LEVELS[idx.clamp(0, Constants::HORIZON_LEVELS.size - 1)]
          end
        end
      end
    end
  end
end
