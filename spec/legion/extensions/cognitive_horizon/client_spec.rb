# frozen_string_literal: true

require 'legion/extensions/cognitive_horizon/client'

RSpec.describe Legion::Extensions::CognitiveHorizon::Client do
  let(:client) { described_class.new }

  it 'responds to get_horizon' do
    expect(client).to respond_to(:get_horizon)
  end

  it 'responds to expand_horizon' do
    expect(client).to respond_to(:expand_horizon)
  end

  it 'responds to contract_horizon' do
    expect(client).to respond_to(:contract_horizon)
  end

  it 'responds to apply_stress' do
    expect(client).to respond_to(:apply_stress)
  end

  it 'responds to relieve_stress' do
    expect(client).to respond_to(:relieve_stress)
  end

  it 'responds to add_projection' do
    expect(client).to respond_to(:add_projection)
  end

  it 'responds to projections_within_horizon' do
    expect(client).to respond_to(:projections_within_horizon)
  end

  it 'responds to beyond_horizon_projections' do
    expect(client).to respond_to(:beyond_horizon_projections)
  end

  it 'responds to nearest_projections' do
    expect(client).to respond_to(:nearest_projections)
  end

  it 'responds to farthest_projections' do
    expect(client).to respond_to(:farthest_projections)
  end

  it 'responds to horizon_status' do
    expect(client).to respond_to(:horizon_status)
  end

  it 'each instance has independent state' do
    c1 = described_class.new
    c2 = described_class.new
    c1.expand_horizon(amount: 0.3)
    expect(c1.get_horizon[:horizon][:current_horizon]).not_to eq(c2.get_horizon[:horizon][:current_horizon])
  end
end
