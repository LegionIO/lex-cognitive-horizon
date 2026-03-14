# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveHorizon
      module Runners
        module CognitiveHorizon
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def get_horizon(**)
            report = horizon_engine.horizon_report
            Legion::Logging.debug "[cognitive_horizon] get_horizon: effective=#{report[:effective_horizon].round(2)} construal=#{report[:construal_label]}"
            { found: true, horizon: report }
          end

          def expand_horizon(amount: nil, **)
            amt    = amount || Helpers::Constants::HORIZON_EXPAND
            before = horizon_engine.current_horizon
            after  = horizon_engine.expand_horizon!(amount: amt)
            Legion::Logging.info "[cognitive_horizon] expand: #{before.round(2)} -> #{after.round(2)} (amount=#{amt})"
            { expanded: true, before: before.round(10), after: after.round(10), amount: amt }
          end

          def contract_horizon(amount: nil, **)
            amt    = amount || Helpers::Constants::HORIZON_CONTRACT
            before = horizon_engine.current_horizon
            after  = horizon_engine.contract_horizon!(amount: amt)
            Legion::Logging.info "[cognitive_horizon] contract: #{before.round(2)} -> #{after.round(2)} (amount=#{amt})"
            { contracted: true, before: before.round(10), after: after.round(10), amount: amt }
          end

          def apply_stress(level:, **)
            before = horizon_engine.current_horizon
            after  = horizon_engine.apply_stress!(level)
            Legion::Logging.info "[cognitive_horizon] stress applied: level=#{level} horizon #{before.round(2)} -> #{after.round(2)}"
            {
              stress_applied: true,
              stress_level:   level,
              before:         before.round(10),
              after:          after.round(10)
            }
          end

          def relieve_stress(amount: nil, **)
            amt    = amount || 0.1
            before = horizon_engine.stress_level
            horizon_engine.relieve_stress!(amount: amt)
            after = horizon_engine.stress_level
            Legion::Logging.debug "[cognitive_horizon] relieve_stress: #{before.round(2)} -> #{after.round(2)}"
            { relieved: true, before: before.round(10), after: after.round(10), amount: amt }
          end

          def add_projection(description:, domain: :general, horizon_distance: nil, confidence: 1.0, **)
            proj = horizon_engine.add_projection(
              description:      description,
              domain:           domain,
              horizon_distance: horizon_distance,
              confidence:       confidence
            )
            Legion::Logging.debug "[cognitive_horizon] add_projection: id=#{proj.id} distance=#{proj.horizon_distance.round(2)} construal=#{proj.construal_level}"
            proj.to_h
          end

          def projections_within_horizon(**)
            within = horizon_engine.projections_within_horizon
            Legion::Logging.debug "[cognitive_horizon] within_horizon: count=#{within.size} effective=#{horizon_engine.effective_horizon.round(2)}"
            { count: within.size, projections: within.map(&:to_h), effective_horizon: horizon_engine.effective_horizon.round(10) }
          end

          def beyond_horizon_projections(**)
            beyond = horizon_engine.beyond_horizon_projections
            Legion::Logging.debug "[cognitive_horizon] beyond_horizon: count=#{beyond.size}"
            { count: beyond.size, projections: beyond.map(&:to_h), effective_horizon: horizon_engine.effective_horizon.round(10) }
          end

          def nearest_projections(n: 5, **)
            projs = horizon_engine.nearest_projections(n: n)
            Legion::Logging.debug "[cognitive_horizon] nearest_projections: n=#{n} returned=#{projs.size}"
            { count: projs.size, projections: projs.map(&:to_h) }
          end

          def farthest_projections(n: 5, **)
            projs = horizon_engine.farthest_projections(n: n)
            Legion::Logging.debug "[cognitive_horizon] farthest_projections: n=#{n} returned=#{projs.size}"
            { count: projs.size, projections: projs.map(&:to_h) }
          end

          def horizon_status(**)
            { total_projections: horizon_engine.projections.size, report: horizon_engine.horizon_report }
          end

          private

          def horizon_engine
            @horizon_engine ||= Helpers::HorizonEngine.new
          end
        end
      end
    end
  end
end
