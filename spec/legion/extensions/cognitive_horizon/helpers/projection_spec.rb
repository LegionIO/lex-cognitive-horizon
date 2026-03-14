# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveHorizon::Helpers::Projection do
  let(:proj) { described_class.new(description: 'Deploy new feature', domain: :code, horizon_distance: 0.4) }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(proj.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets description' do
      expect(proj.description).to eq('Deploy new feature')
    end

    it 'sets domain' do
      expect(proj.domain).to eq(:code)
    end

    it 'sets horizon_distance' do
      expect(proj.horizon_distance).to eq(0.4)
    end

    it 'defaults confidence to 1.0' do
      expect(proj.confidence).to eq(1.0)
    end

    it 'sets created_at' do
      expect(proj.created_at).to be_a(Time)
    end

    it 'clamps horizon_distance above 1.0 to 1.0' do
      p = described_class.new(description: 'x', horizon_distance: 1.5)
      expect(p.horizon_distance).to eq(1.0)
    end

    it 'clamps horizon_distance below 0.0 to 0.0' do
      p = described_class.new(description: 'x', horizon_distance: -0.5)
      expect(p.horizon_distance).to eq(0.0)
    end

    it 'clamps confidence above 1.0 to 1.0' do
      p = described_class.new(description: 'x', confidence: 2.0)
      expect(p.confidence).to eq(1.0)
    end

    it 'clamps confidence below 0.0 to 0.0' do
      p = described_class.new(description: 'x', confidence: -0.1)
      expect(p.confidence).to eq(0.0)
    end

    it 'accepts explicit construal_level' do
      p = described_class.new(description: 'x', construal_level: :abstract)
      expect(p.construal_level).to eq(:abstract)
    end
  end

  describe '#concrete?' do
    it 'returns true for distance <= 0.3' do
      p = described_class.new(description: 'x', horizon_distance: 0.2)
      expect(p.concrete?).to be true
    end

    it 'returns true at exactly 0.3' do
      p = described_class.new(description: 'x', horizon_distance: 0.3)
      expect(p.concrete?).to be true
    end

    it 'returns false for distance > 0.3' do
      p = described_class.new(description: 'x', horizon_distance: 0.5)
      expect(p.concrete?).to be false
    end
  end

  describe '#abstract?' do
    it 'returns true for distance >= 0.7' do
      p = described_class.new(description: 'x', horizon_distance: 0.8)
      expect(p.abstract?).to be true
    end

    it 'returns true at exactly 0.7' do
      p = described_class.new(description: 'x', horizon_distance: 0.7)
      expect(p.abstract?).to be true
    end

    it 'returns false for distance < 0.7' do
      p = described_class.new(description: 'x', horizon_distance: 0.5)
      expect(p.abstract?).to be false
    end
  end

  describe '#construal_level derived' do
    it 'derives :concrete for distance 0.1' do
      p = described_class.new(description: 'x', horizon_distance: 0.1)
      expect(p.construal_level).to eq(:concrete)
    end

    it 'derives :balanced for distance 0.5' do
      p = described_class.new(description: 'x', horizon_distance: 0.5)
      expect(p.construal_level).to eq(:balanced)
    end

    it 'derives :abstract for distance 0.9' do
      p = described_class.new(description: 'x', horizon_distance: 0.9)
      expect(p.construal_level).to eq(:abstract)
    end
  end

  describe '#to_h' do
    let(:h) { proj.to_h }

    it 'includes id' do
      expect(h[:id]).to eq(proj.id)
    end

    it 'includes description' do
      expect(h[:description]).to eq('Deploy new feature')
    end

    it 'includes domain' do
      expect(h[:domain]).to eq(:code)
    end

    it 'includes horizon_distance rounded to 10 places' do
      expect(h[:horizon_distance]).to eq(proj.horizon_distance.round(10))
    end

    it 'includes confidence rounded to 10 places' do
      expect(h[:confidence]).to eq(proj.confidence.round(10))
    end

    it 'includes construal_level' do
      expect(h[:construal_level]).to be_a(Symbol)
    end

    it 'includes concrete flag' do
      expect(h).to have_key(:concrete)
    end

    it 'includes abstract flag' do
      expect(h).to have_key(:abstract)
    end

    it 'includes created_at' do
      expect(h[:created_at]).to be_a(Time)
    end
  end

  describe 'unique IDs' do
    it 'generates different IDs for different projections' do
      p1 = described_class.new(description: 'a')
      p2 = described_class.new(description: 'b')
      expect(p1.id).not_to eq(p2.id)
    end
  end
end
