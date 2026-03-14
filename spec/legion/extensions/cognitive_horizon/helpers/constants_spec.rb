# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveHorizon::Helpers::Constants do
  describe 'numeric constants' do
    it 'MAX_PROJECTIONS is 200' do
      expect(described_module::MAX_PROJECTIONS).to eq(200)
    end

    it 'DEFAULT_HORIZON is 0.5' do
      expect(described_module::DEFAULT_HORIZON).to eq(0.5)
    end

    it 'HORIZON_EXPAND is 0.08' do
      expect(described_module::HORIZON_EXPAND).to eq(0.08)
    end

    it 'HORIZON_CONTRACT is 0.1' do
      expect(described_module::HORIZON_CONTRACT).to eq(0.1)
    end

    it 'MIN_HORIZON is 0.1' do
      expect(described_module::MIN_HORIZON).to eq(0.1)
    end

    it 'MAX_HORIZON is 1.0' do
      expect(described_module::MAX_HORIZON).to eq(1.0)
    end

    it 'STRESS_CONTRACTION is 0.15' do
      expect(described_module::STRESS_CONTRACTION).to eq(0.15)
    end

    it 'CONFIDENCE_DECAY_PER_STEP is 0.1' do
      expect(described_module::CONFIDENCE_DECAY_PER_STEP).to eq(0.1)
    end
  end

  describe 'HORIZON_LEVELS' do
    it 'has 5 levels' do
      expect(described_module::HORIZON_LEVELS.size).to eq(5)
    end

    it 'starts with :immediate' do
      expect(described_module::HORIZON_LEVELS.first).to eq(:immediate)
    end

    it 'ends with :strategic' do
      expect(described_module::HORIZON_LEVELS.last).to eq(:strategic)
    end

    it 'contains :near_term, :medium_term, :long_term' do
      expect(described_module::HORIZON_LEVELS).to include(:near_term, :medium_term, :long_term)
    end

    it 'is frozen' do
      expect(described_module::HORIZON_LEVELS).to be_frozen
    end
  end

  describe 'CONSTRUAL_LABELS' do
    it 'has 5 entries' do
      expect(described_module::CONSTRUAL_LABELS.size).to eq(5)
    end

    it 'maps low distances to :concrete' do
      entry = described_module::CONSTRUAL_LABELS.find { |e| e[:range].cover?(0.1) }
      expect(entry[:label]).to eq(:concrete)
    end

    it 'maps mid distances to :balanced' do
      entry = described_module::CONSTRUAL_LABELS.find { |e| e[:range].cover?(0.5) }
      expect(entry[:label]).to eq(:balanced)
    end

    it 'maps high distances to :abstract' do
      entry = described_module::CONSTRUAL_LABELS.find { |e| e[:range].cover?(0.9) }
      expect(entry[:label]).to eq(:abstract)
    end

    it 'maps 0.3 to :detailed' do
      entry = described_module::CONSTRUAL_LABELS.find { |e| e[:range].cover?(0.3) }
      expect(entry[:label]).to eq(:detailed)
    end

    it 'maps 0.7 to :schematic' do
      entry = described_module::CONSTRUAL_LABELS.find { |e| e[:range].cover?(0.7) }
      expect(entry[:label]).to eq(:schematic)
    end

    it 'is frozen' do
      expect(described_module::CONSTRUAL_LABELS).to be_frozen
    end
  end

  def described_module
    Legion::Extensions::CognitiveHorizon::Helpers::Constants
  end
end
