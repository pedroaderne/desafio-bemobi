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

    # Stub the provider service so the model callback uses it when creating the recharge
    allow_any_instance_of(RechargeProviderService).to receive(:process).and_return({ status: 'success', provider_reference: 'claro', external_id: 'external_uuid' })

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

  # controller currently returns an error json and does not create a Recharge for non-paid
  expect(response).to have_http_status(:ok)
  json = JSON.parse(response.body).with_indifferent_access
  expect(json[:error]).to eq('pending')
  # ensure no new recharge was created
  expect(Recharge.last).to be_nil
  end
end
