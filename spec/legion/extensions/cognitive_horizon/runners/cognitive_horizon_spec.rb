# frozen_string_literal: true

require 'legion/extensions/cognitive_horizon/client'

RSpec.describe Legion::Extensions::CognitiveHorizon::Runners::CognitiveHorizon do
  let(:client) { Legion::Extensions::CognitiveHorizon::Client.new }

  describe '#get_horizon' do
    it 'returns found: true' do
      result = client.get_horizon
      expect(result[:found]).to be true
    end

    it 'includes a horizon report' do
      result = client.get_horizon
      expect(result[:horizon]).to be_a(Hash)
    end

    it 'horizon report includes current_horizon' do
      result = client.get_horizon
      expect(result[:horizon]).to have_key(:current_horizon)
    end

    it 'horizon report includes construal_label' do
      result = client.get_horizon
      expect(result[:horizon]).to have_key(:construal_label)
    end

    it 'horizon report includes effective_horizon' do
      result = client.get_horizon
      expect(result[:horizon]).to have_key(:effective_horizon)
    end
  end

  describe '#expand_horizon' do
    it 'returns expanded: true' do
      result = client.expand_horizon
      expect(result[:expanded]).to be true
    end

    it 'after is greater than before' do
      result = client.expand_horizon
      expect(result[:after]).to be > result[:before]
    end

    it 'returns the default amount' do
      result = client.expand_horizon
      expect(result[:amount]).to eq(Legion::Extensions::CognitiveHorizon::Helpers::Constants::HORIZON_EXPAND)
    end

    it 'accepts custom amount' do
      result = client.expand_horizon(amount: 0.2)
      expect(result[:amount]).to eq(0.2)
    end

    it 'does not exceed 1.0' do
      10.times { client.expand_horizon(amount: 0.2) }
      result = client.get_horizon
      expect(result[:horizon][:current_horizon]).to be <= 1.0
    end
  end

  describe '#contract_horizon' do
    it 'returns contracted: true' do
      result = client.contract_horizon
      expect(result[:contracted]).to be true
    end

    it 'after is less than before' do
      result = client.contract_horizon
      expect(result[:after]).to be < result[:before]
    end

    it 'returns the default amount' do
      result = client.contract_horizon
      expect(result[:amount]).to eq(Legion::Extensions::CognitiveHorizon::Helpers::Constants::HORIZON_CONTRACT)
    end

    it 'does not go below MIN_HORIZON' do
      10.times { client.contract_horizon(amount: 0.2) }
      result = client.get_horizon
      expect(result[:horizon][:current_horizon]).to be >= Legion::Extensions::CognitiveHorizon::Helpers::Constants::MIN_HORIZON
    end
  end

  describe '#apply_stress' do
    it 'returns stress_applied: true' do
      result = client.apply_stress(level: 0.5)
      expect(result[:stress_applied]).to be true
    end

    it 'records the stress level' do
      result = client.apply_stress(level: 0.6)
      expect(result[:stress_level]).to eq(0.6)
    end

    it 'decreases the horizon' do
      result = client.apply_stress(level: 0.8)
      expect(result[:after]).to be <= result[:before]
    end

    it 'contracts horizon with high stress' do
      initial = client.get_horizon[:horizon][:current_horizon]
      client.apply_stress(level: 1.0)
      final = client.get_horizon[:horizon][:current_horizon]
      expect(final).to be < initial
    end
  end

  describe '#relieve_stress' do
    before { client.apply_stress(level: 0.8) }

    it 'returns relieved: true' do
      result = client.relieve_stress
      expect(result[:relieved]).to be true
    end

    it 'reduces stress level' do
      result = client.relieve_stress
      expect(result[:after]).to be < result[:before]
    end

    it 'accepts custom amount' do
      result = client.relieve_stress(amount: 0.3)
      expect(result[:amount]).to eq(0.3)
    end
  end

  describe '#add_projection' do
    it 'returns a hash with an id' do
      result = client.add_projection(description: 'Future state')
      expect(result[:id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'includes description' do
      result = client.add_projection(description: 'Future state')
      expect(result[:description]).to eq('Future state')
    end

    it 'uses default domain :general' do
      result = client.add_projection(description: 'x')
      expect(result[:domain]).to eq(:general)
    end

    it 'accepts custom domain' do
      result = client.add_projection(description: 'x', domain: :ops)
      expect(result[:domain]).to eq(:ops)
    end

    it 'returns horizon_distance' do
      result = client.add_projection(description: 'x', horizon_distance: 0.7)
      expect(result[:horizon_distance]).to eq(0.7)
    end

    it 'returns construal_level' do
      result = client.add_projection(description: 'x')
      expect(result[:construal_level]).to be_a(Symbol)
    end
  end

  describe '#projections_within_horizon' do
    before do
      client.add_projection(description: 'near', horizon_distance: 0.1)
      client.add_projection(description: 'far', horizon_distance: 0.99)
    end

    it 'returns count' do
      result = client.projections_within_horizon
      expect(result[:count]).to be_a(Integer)
    end

    it 'returns projections array' do
      result = client.projections_within_horizon
      expect(result[:projections]).to be_an(Array)
    end

    it 'includes effective_horizon' do
      result = client.projections_within_horizon
      expect(result[:effective_horizon]).to be_a(Float)
    end

    it 'all returned projections are within effective_horizon' do
      result = client.projections_within_horizon
      result[:projections].each do |p|
        expect(p[:horizon_distance]).to be <= result[:effective_horizon]
      end
    end
  end

  describe '#beyond_horizon_projections' do
    before do
      client.add_projection(description: 'near', horizon_distance: 0.1)
      client.add_projection(description: 'far', horizon_distance: 0.99)
    end

    it 'returns count' do
      result = client.beyond_horizon_projections
      expect(result[:count]).to be_a(Integer)
    end

    it 'all returned projections are beyond effective_horizon' do
      result = client.beyond_horizon_projections
      eff = result[:effective_horizon]
      result[:projections].each do |p|
        expect(p[:horizon_distance]).to be > eff
      end
    end

    it 'within + beyond == total' do
      within_count = client.projections_within_horizon[:count]
      beyond_count = client.beyond_horizon_projections[:count]
      total = client.horizon_status[:total_projections]
      expect(within_count + beyond_count).to eq(total)
    end
  end

  describe '#nearest_projections' do
    before do
      [0.9, 0.1, 0.5].each { |d| client.add_projection(description: "p#{d}", horizon_distance: d) }
    end

    it 'returns count' do
      result = client.nearest_projections(n: 2)
      expect(result[:count]).to eq(2)
    end

    it 'returns projections sorted nearest first' do
      result = client.nearest_projections(n: 2)
      distances = result[:projections].map { |p| p[:horizon_distance] }
      expect(distances).to eq(distances.sort)
    end

    it 'defaults to n=5' do
      5.times { |i| client.add_projection(description: "extra #{i}", horizon_distance: 0.3) }
      result = client.nearest_projections
      expect(result[:count]).to be <= 5
    end
  end

  describe '#farthest_projections' do
    before do
      [0.9, 0.1, 0.5].each { |d| client.add_projection(description: "p#{d}", horizon_distance: d) }
    end

    it 'returns projections sorted farthest first' do
      result = client.farthest_projections(n: 2)
      distances = result[:projections].map { |p| p[:horizon_distance] }
      expect(distances).to eq(distances.sort.reverse)
    end

    it 'returns correct count' do
      result = client.farthest_projections(n: 2)
      expect(result[:count]).to eq(2)
    end
  end

  describe '#horizon_status' do
    it 'returns total_projections' do
      client.add_projection(description: 'test')
      result = client.horizon_status
      expect(result[:total_projections]).to eq(1)
    end

    it 'includes a report hash' do
      result = client.horizon_status
      expect(result[:report]).to be_a(Hash)
    end
  end
end
