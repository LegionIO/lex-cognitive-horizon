# lex-cognitive-horizon

Temporal planning horizon engine for brain-modeled agentic AI in the LegionIO ecosystem.

## What It Does

Models how far ahead an agent can effectively plan. The horizon (0.0 to 1.0) represents planning depth and can be expanded through deliberate effort or contracted under stress. Stress narrows the effective horizon without touching the underlying capacity — stress relief fully restores effective reach. Projections are forward-looking cognitive estimates at a given temporal distance; only projections within the effective horizon are considered actionable. Confidence in projections decays with temporal distance. A background actor runs every 60 seconds to sample horizon status.

## Usage

```ruby
require 'legion/extensions/cognitive_horizon'

client = Legion::Extensions::CognitiveHorizon::Client.new

# Check current horizon state
client.get_horizon
# => { success: true, current: 0.5, effective: 0.5, stress: 0.0, label: :moderate }

# Expand planning depth
client.expand_horizon
# => { success: true, before: 0.5, after: 0.58, label: :moderate }

# Add a forward projection
client.add_projection(
  content: 'complete API auth layer',
  domain: :engineering,
  temporal_distance: 0.3,
  confidence: 0.8
)

# Apply stress (narrows effective horizon)
client.apply_stress(amount: 0.5)
# => { success: true, stress: 0.5, effective_horizon: 0.505 }

# See which projections are still within reach
client.projections_within_horizon
# => { success: true, projections: [...] }

# Relieve stress to restore full effective horizon
client.relieve_stress(amount: 0.5)
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
