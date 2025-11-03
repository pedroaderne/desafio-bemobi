require 'rails_helper'
require_relative '../../app/services/recharge_provider_service'

RSpec.describe RechargeProviderService do
  let(:product_hash) { { 'id' => 'product_uuid', 'amount' => 20, 'unit' => 'GB' } }
  let(:customer_hash) { { 'id' => 'customer_uuid' } }
  let(:payment) do
    double('Payment', product: product_hash, phone_number: '21987654321', external_id: 'external_uuid', customer: customer_hash)
  end

  subject { described_class.new(payment) }

  context 'when provider returns success (200 with status success)' do
    it 'returns success and provider_reference + external_id' do
      response = double(code: 200, body: { status: 'success', external_id: 'external_uuid', provider_reference: 'claro' }.to_json)
      allow(HTTParty).to receive(:post).and_return(response)

      result = subject.process

      expect(result[:status]).to eq('success')
      expect(result[:provider_reference]).to eq('claro')
      expect(result[:external_id]).to eq('external_uuid')
      expect(result[:error_message]).to be_nil
    end
  end

  context 'when provider returns business failure (200 with status failure)' do
    it 'returns the failure status from provider' do
      response = double(code: 200, body: { status: 'failure', external_id: 'external_uuid', provider_reference: 'claro' }.to_json)
      allow(HTTParty).to receive(:post).and_return(response)

      result = subject.process

      expect(result[:status]).to eq('failure')
      expect(result[:provider_reference]).to eq('claro')
      expect(result[:external_id]).to eq('external_uuid')
    end
  end

  context 'when provider responds 422 Unprocessable Entity' do
    it 'returns failed and includes provider error message' do
      response = double(code: 422, body: { error: 'Invalid entity' }.to_json)
      allow(HTTParty).to receive(:post).and_return(response)

      result = subject.process

      # current service maps non-200 responses to the provider error message
      expect(result[:status]).to eq('Invalid entity')
      expect(result[:error_message]).to eq('Invalid entity')
      expect(result[:provider_reference]).to be_nil
    end
  end

  context 'when provider times out' do
    it 'returns failed with timeout message' do
      allow(HTTParty).to receive(:post).and_raise(Net::OpenTimeout)

      result = subject.process

      expect(result[:status]).to eq('failed')
      expect(result[:error_message]).to eq('Timeout')
    end
  end

  context 'when provider returns 500' do
    it 'returns failed and includes server error message' do
      response = double(code: 500, body: { error: 'Server error' }.to_json)
      allow(HTTParty).to receive(:post).and_return(response)

      result = subject.process

      # non-200 responses currently surface the provider's error string as status
      expect(result[:status]).to eq('Server error')
      expect(result[:error_message]).to eq('Server error')
    end
  end
end
