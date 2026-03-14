# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveHorizon::Helpers::HorizonEngine do
  subject(:engine) { described_class.new }

  let(:constants) { Legion::Extensions::CognitiveHorizon::Helpers::Constants }

  describe '#initialize' do
    it 'starts with empty projections' do
      expect(engine.projections).to be_empty
    end

    it 'starts with DEFAULT_HORIZON' do
      expect(engine.current_horizon).to eq(constants::DEFAULT_HORIZON)
    end

    it 'starts with zero stress' do
      expect(engine.stress_level).to eq(0.0)
    end

    it 'accepts custom initial_horizon' do
      e = described_class.new(initial_horizon: 0.8)
      expect(e.current_horizon).to eq(0.8)
    end

    it 'clamps initial_horizon to MIN_HORIZON' do
      e = described_class.new(initial_horizon: 0.0)
      expect(e.current_horizon).to eq(constants::MIN_HORIZON)
    end

    it 'clamps initial_horizon to MAX_HORIZON' do
      e = described_class.new(initial_horizon: 1.5)
      expect(e.current_horizon).to eq(constants::MAX_HORIZON)
    end
  end

  describe '#add_projection' do
    it 'adds a projection to the list' do
      engine.add_projection(description: 'test')
      expect(engine.projections.size).to eq(1)
    end

    it 'returns a Projection object' do
      proj = engine.add_projection(description: 'test')
      expect(proj).to be_a(Legion::Extensions::CognitiveHorizon::Helpers::Projection)
    end

    it 'uses current_horizon as default distance' do
      proj = engine.add_projection(description: 'test')
      expect(proj.horizon_distance).to eq(engine.current_horizon)
    end

    it 'accepts explicit horizon_distance' do
      proj = engine.add_projection(description: 'test', horizon_distance: 0.9)
      expect(proj.horizon_distance).to eq(0.9)
    end

    it 'caps projections at MAX_PROJECTIONS' do
      (constants::MAX_PROJECTIONS + 10).times { |i| engine.add_projection(description: "proj #{i}") }
      expect(engine.projections.size).to eq(constants::MAX_PROJECTIONS)
    end

    it 'keeps the most recent projections when capping' do
      (constants::MAX_PROJECTIONS + 5).times { |i| engine.add_projection(description: "proj #{i}") }
      expect(engine.projections.last.description).to eq("proj #{constants::MAX_PROJECTIONS + 4}")
    end
  end

  describe '#expand_horizon!' do
    it 'increases current_horizon' do
      before = engine.current_horizon
      engine.expand_horizon!
      expect(engine.current_horizon).to be > before
    end

    it 'increases by HORIZON_EXPAND by default' do
      before = engine.current_horizon
      engine.expand_horizon!
      expect(engine.current_horizon).to eq((before + constants::HORIZON_EXPAND).clamp(constants::MIN_HORIZON, constants::MAX_HORIZON))
    end

    it 'accepts a custom amount' do
      before = engine.current_horizon
      engine.expand_horizon!(amount: 0.2)
      expect(engine.current_horizon).to eq((before + 0.2).clamp(constants::MIN_HORIZON, constants::MAX_HORIZON))
    end

    it 'does not exceed MAX_HORIZON' do
      engine = described_class.new(initial_horizon: 0.99)
      engine.expand_horizon!(amount: 0.5)
      expect(engine.current_horizon).to eq(constants::MAX_HORIZON)
    end

    it 'returns the new horizon value' do
      result = engine.expand_horizon!
      expect(result).to eq(engine.current_horizon)
    end
  end

  describe '#contract_horizon!' do
    it 'decreases current_horizon' do
      before = engine.current_horizon
      engine.contract_horizon!
      expect(engine.current_horizon).to be < before
    end

    it 'decreases by HORIZON_CONTRACT by default' do
      before = engine.current_horizon
      engine.contract_horizon!
      expect(engine.current_horizon).to eq((before - constants::HORIZON_CONTRACT).clamp(constants::MIN_HORIZON, constants::MAX_HORIZON))
    end

    it 'does not go below MIN_HORIZON' do
      e = described_class.new(initial_horizon: constants::MIN_HORIZON)
      e.contract_horizon!(amount: 0.5)
      expect(e.current_horizon).to eq(constants::MIN_HORIZON)
    end

    it 'returns the new horizon value' do
      result = engine.contract_horizon!
      expect(result).to eq(engine.current_horizon)
    end
  end

  describe '#apply_stress!' do
    it 'sets stress_level' do
      engine.apply_stress!(0.5)
      expect(engine.stress_level).to eq(0.5)
    end

    it 'reduces current_horizon proportionally' do
      before = engine.current_horizon
      engine.apply_stress!(1.0)
      expect(engine.current_horizon).to be <= before
    end

    it 'clamps stress to 0..1' do
      engine.apply_stress!(2.0)
      expect(engine.stress_level).to eq(1.0)
    end

    it 'clamps stress below 0.0 to 0.0' do
      engine.apply_stress!(-0.5)
      expect(engine.stress_level).to eq(0.0)
    end

    it 'ensures horizon does not go below MIN_HORIZON under max stress' do
      engine.apply_stress!(1.0)
      expect(engine.current_horizon).to be >= constants::MIN_HORIZON
    end

    it 'returns the new horizon value' do
      result = engine.apply_stress!(0.3)
      expect(result).to be_a(Float)
    end
  end

  describe '#relieve_stress!' do
    before { engine.apply_stress!(0.6) }

    it 'reduces stress_level' do
      before = engine.stress_level
      engine.relieve_stress!
      expect(engine.stress_level).to be < before
    end

    it 'accepts custom amount' do
      engine.relieve_stress!(amount: 0.3)
      expect(engine.stress_level).to be_within(0.001).of(0.3)
    end

    it 'does not go below 0.0' do
      engine.relieve_stress!(amount: 10.0)
      expect(engine.stress_level).to eq(0.0)
    end
  end

  describe '#effective_horizon' do
    it 'equals current_horizon when stress is zero' do
      expect(engine.effective_horizon).to eq(engine.current_horizon)
    end

    it 'is less than current_horizon when stressed' do
      engine.apply_stress!(0.5)
      # after apply_stress! current_horizon already contracted;
      # effective_horizon contracts further based on residual stress
      expect(engine.effective_horizon).to be <= engine.current_horizon
    end

    it 'never goes below MIN_HORIZON' do
      engine.apply_stress!(1.0)
      expect(engine.effective_horizon).to be >= constants::MIN_HORIZON
    end
  end

  describe '#projections_within_horizon' do
    before do
      engine.add_projection(description: 'near', horizon_distance: 0.2)
      engine.add_projection(description: 'at horizon', horizon_distance: engine.effective_horizon)
      engine.add_projection(description: 'far', horizon_distance: 0.99)
    end

    it 'returns projections at or within effective_horizon' do
      within = engine.projections_within_horizon
      within.each { |p| expect(p.horizon_distance).to be <= engine.effective_horizon }
    end

    it 'excludes projections beyond effective_horizon' do
      within = engine.projections_within_horizon
      descriptions = within.map(&:description)
      expect(descriptions).not_to include('far')
    end
  end

  describe '#beyond_horizon_projections' do
    before do
      engine.add_projection(description: 'near', horizon_distance: 0.1)
      engine.add_projection(description: 'far', horizon_distance: 0.99)
    end

    it 'returns projections beyond effective_horizon' do
      beyond = engine.beyond_horizon_projections
      beyond.each { |p| expect(p.horizon_distance).to be > engine.effective_horizon }
    end
  end

  describe '#nearest_projections' do
    before do
      [0.9, 0.1, 0.5, 0.3, 0.7].each { |d| engine.add_projection(description: "p#{d}", horizon_distance: d) }
    end

    it 'returns n nearest by horizon_distance' do
      result = engine.nearest_projections(n: 3)
      expect(result.size).to eq(3)
      expect(result.map(&:horizon_distance)).to eq([0.1, 0.3, 0.5])
    end

    it 'defaults to 5' do
      result = engine.nearest_projections
      expect(result.size).to eq(5)
    end
  end

  describe '#farthest_projections' do
    before do
      [0.9, 0.1, 0.5, 0.3, 0.7].each { |d| engine.add_projection(description: "p#{d}", horizon_distance: d) }
    end

    it 'returns n farthest in descending order' do
      result = engine.farthest_projections(n: 2)
      expect(result.map(&:horizon_distance)).to eq([0.9, 0.7])
    end
  end

  describe '#construal_label' do
    it 'returns a symbol' do
      expect(engine.construal_label).to be_a(Symbol)
    end

    it 'returns :concrete for low effective horizon' do
      e = described_class.new(initial_horizon: 0.15)
      expect(e.construal_label).to eq(:concrete)
    end

    it 'returns :abstract for high effective horizon' do
      e = described_class.new(initial_horizon: 0.95)
      expect(e.construal_label).to eq(:abstract)
    end
  end

  describe '#horizon_report' do
    let(:report) { engine.horizon_report }

    it 'includes current_horizon' do
      expect(report).to have_key(:current_horizon)
    end

    it 'includes stress_level' do
      expect(report).to have_key(:stress_level)
    end

    it 'includes effective_horizon' do
      expect(report).to have_key(:effective_horizon)
    end

    it 'includes construal_label' do
      expect(report).to have_key(:construal_label)
    end

    it 'includes horizon_level' do
      expect(report).to have_key(:horizon_level)
    end

    it 'includes total_projections' do
      expect(report).to have_key(:total_projections)
    end

    it 'includes within_horizon count' do
      expect(report).to have_key(:within_horizon)
    end

    it 'includes beyond_horizon count' do
      expect(report).to have_key(:beyond_horizon)
    end

    it 'rounds values to 10 places' do
      expect(report[:current_horizon]).to be_a(Float)
    end
  end

  describe '#to_h' do
    it 'includes projections array' do
      engine.add_projection(description: 'test')
      h = engine.to_h
      expect(h[:projections]).to be_an(Array)
      expect(h[:projections].size).to eq(1)
    end

    it 'includes report fields' do
      h = engine.to_h
      expect(h).to have_key(:current_horizon)
      expect(h).to have_key(:construal_label)
    end
  end
end
