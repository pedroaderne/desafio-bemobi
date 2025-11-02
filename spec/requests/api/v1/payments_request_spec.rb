require 'rails_helper'

RSpec.describe 'Api::V1::Payments', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }

  it 'creates a recharge when payment status is paid' do
    payload = {
      phone_number: '21987654321',
      amount_in_cents: 1000,
      status: 'paid',
      external_id: 'ext-1',
      product: { id: 'prod', amount: 20, unit: 'GB' },
      customer: { id: 'cust' }
    }

    payment = Payment.create!(phone_number: payload[:phone_number], amount_in_cents: payload[:amount_in_cents], status: payload[:status], external_id: payload[:external_id], product: payload[:product], customer: payload[:customer])
    expected_recharge = Recharge.create!(payment: payment, status: 'success', provider_reference: 'claro', external_id: 'external_uuid')
    allow(Recharge).to receive(:get_recharge_from_payment).with(instance_of(Payment)).and_return(expected_recharge)

  post '/api/v1/payments', params: payload.to_json, headers: headers

  expect(response).to have_http_status(:ok)
  last = Recharge.last
  expect(last).not_to be_nil
  expect(last.status).to eq('success')
  expect(last.provider_reference).to eq('claro')
  end

  it 'creates failed recharge when payment not paid' do
    payload = {
      phone_number: '21911111111',
      amount_in_cents: 500,
      status: 'pending',
      external_id: 'ext-2',
      product: { id: 'prod', amount: 20, unit: 'GB' },
      customer: { id: 'cust' }
    }

  post '/api/v1/payments', params: payload.to_json, headers: headers

  expect(response).to have_http_status(:ok)
  last = Recharge.last
  expect(last).not_to be_nil
  expect(last.status).to eq('failed')
  expect(last.error_message).to eq('Payment failed')
  end
end
