require 'rails_helper'

RSpec.describe Recharge, type: :model do
  describe '.get_recharge_from_payment' do
    let(:payment) { Payment.create!(phone_number: '21987654321', amount_in_cents: 1000, status: 'paid', external_id: 'p-ext', product: { 'id' => 'prod' }, customer: { 'id' => 'cust' }) }

    it 'creates a recharge with provider response data' do
      resp = { status: 'success', provider_reference: 'claro', external_id: 'external_uuid' }
      allow(RechargeProviderService).to receive_message_chain(:new, :process).and_return(resp)

      recharge = Recharge.get_recharge_from_payment(payment)

      expect(recharge).to be_persisted
      expect(recharge.status).to eq('success')
      expect(recharge.provider_reference).to eq('claro')
      expect(recharge.external_id).to eq('external_uuid')
      expect(recharge.payment).to eq(payment)
    end
  end
end
