# lex-cognitive-horizon

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-horizon`

## Purpose

Models the temporal horizon of cognitive planning — how far ahead the agent can effectively project. The horizon is a float in [0.0, 1.0] representing planning depth. It expands through deliberate effort and contracts under stress. Each added projection carries a temporal distance and a confidence that decays with distance from the horizon. The effective horizon = `current_horizon - (stress * STRESS_CONTRACTION)`, meaning stress silently narrows what the agent can see. A periodic actor adjusts the horizon every 60 seconds.

## Gem Info

| Field | Value |
|---|---|
| Gem name | `lex-cognitive-horizon` |
| Version | `0.1.0` |
| Namespace | `Legion::Extensions::CognitiveHorizon` |
| Ruby | `>= 3.4` |
| License | MIT |
| GitHub | https://github.com/LegionIO/lex-cognitive-horizon |

## File Structure

```
lib/legion/extensions/cognitive_horizon/
  cognitive_horizon.rb              # Top-level require
  version.rb                        # VERSION = '0.1.0'
  client.rb                         # Client class
  actors/
    adjust.rb                       # Adjust actor — every 60s, calls horizon_status
  helpers/
    constants.rb                    # Horizon levels, construal labels, decay, contraction rates
    projection.rb                   # Projection value object
    horizon_engine.rb               # Engine: horizon, stress, projections
  runners/
    cognitive_horizon.rb            # Runner module
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_PROJECTIONS` | 200 | Projection store cap |
| `DEFAULT_HORIZON` | 0.5 | Starting horizon breadth |
| `HORIZON_EXPAND` | 0.08 | Horizon increase per expand call |
| `HORIZON_CONTRACT` | 0.1 | Horizon decrease per contract call |
| `STRESS_CONTRACTION` | 0.15 | Multiplier: how much each unit of stress narrows effective horizon |
| `HORIZON_LEVELS` | 5 levels | `vast` (0.9+), `broad`, `moderate`, `narrow`, `minimal` |
| `CONSTRUAL_LABELS` | array | Labels for level-of-construal (abstract to concrete) |
| `CONFIDENCE_DECAY_PER_STEP` | 0.1 | Confidence reduction per unit of temporal distance |

## Helpers

### `Projection`

A forward-looking cognitive estimate at a given temporal distance.

- `initialize(content:, domain:, temporal_distance:, confidence: 1.0, projection_id: nil)`
- `effective_confidence(horizon)` — `confidence - (temporal_distance * CONFIDENCE_DECAY_PER_STEP)`, clamped to 0.0
- `within_horizon?(effective_horizon)` — temporal_distance <= effective_horizon
- `to_h`

### `HorizonEngine`

- `add_projection(content:, domain:, temporal_distance:, confidence: 1.0)` — validates against capacity; appends
- `expand_horizon!(rate: HORIZON_EXPAND)` — increases current_horizon, cap 1.0; returns before/after
- `contract_horizon!(rate: HORIZON_CONTRACT)` — decreases current_horizon, floor 0.0
- `apply_stress!(amount)` — increases stress level; effective_horizon contracts without touching current_horizon
- `relieve_stress!(amount)` — decreases stress level, floor 0.0
- `effective_horizon` — `[current_horizon - (stress * STRESS_CONTRACTION), 0.0].max`
- `projections_within_horizon` — projections where `temporal_distance <= effective_horizon`
- `construal_label` — construal abstraction label based on effective horizon level
- `horizon_report` — full stats including current, effective, stress, projection counts

## Actors

### `Actors::Adjust`

- Interval: every 60 seconds
- Calls `horizon_status` on the runner
- `use_runner? = false`, `generate_task? = false`

## Runners

**Module**: `Legion::Extensions::CognitiveHorizon::Runners::CognitiveHorizon`

| Method | Key Args | Returns |
|---|---|---|
| `get_horizon` | — | `{ success:, current:, effective:, stress:, label: }` |
| `expand_horizon` | `rate: HORIZON_EXPAND` | `{ success:, before:, after:, label: }` |
| `contract_horizon` | `rate: HORIZON_CONTRACT` | `{ success:, before:, after:, label: }` |
| `apply_stress` | `amount:` | `{ success:, stress:, effective_horizon: }` |
| `relieve_stress` | `amount:` | `{ success:, stress:, effective_horizon: }` |
| `add_projection` | `content:`, `domain:`, `temporal_distance:`, `confidence: 1.0` | `{ success:, projection_id:, projection: }` |
| `projections_within_horizon` | — | `{ success:, projections: [...] }` |
| `beyond_horizon_projections` | — | `{ success:, projections: [...] }` |
| `nearest_projections` | `limit: 10` | `{ success:, projections: }` |
| `farthest_projections` | `limit: 10` | `{ success:, projections: }` |
| `horizon_status` | — | `{ success:, report: }` |

Private: `horizon_engine` — memoized `HorizonEngine`. Logs via `log_debug` helper.

## Integration Points

- **`lex-prediction`**: Projections in `lex-cognitive-horizon` are qualitative temporal estimates; predictions in `lex-prediction` are scored probability forecasts. Horizon filters which predictions are worth pursuing; low-horizon agents should restrict prediction to near-term scenarios.
- **`lex-emotion`**: High arousal or fear valence from `lex-emotion` can trigger `apply_stress!` calls, narrowing the effective horizon without changing underlying planning capacity.
- **`lex-tick`**: `horizon_status` is a natural fit for the `action_selection` phase — narrow effective horizon constrains which goals the agent pursues in a given tick.

## Development Notes

- Stress does NOT reduce `current_horizon`; it only reduces `effective_horizon`. Relieving stress restores effective horizon to the full current_horizon immediately. This distinction is intentional: chronic stress vs. momentary anxiety have different recovery dynamics.
- `CONFIDENCE_DECAY_PER_STEP` of 0.1 means projections at temporal_distance 10+ have effective_confidence of 0.0 regardless of assigned confidence.
- The `Adjust` actor calls `horizon_status` (read-only) — it does not autonomously expand or contract the horizon. External agents drive horizon changes via `expand_horizon` and `apply_stress`.
- In-memory only.

---

**Maintained By**: Matthew Iverson (@Esity)
