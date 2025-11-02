require 'rails_helper'

RSpec.describe Payment, type: :model do
  it 'validates uniqueness of external_id' do
    Payment.create!(phone_number: '21999999999', amount_in_cents: 1000, status: 'paid', external_id: 'ext-1')
    dup = Payment.new(phone_number: '21999999998', amount_in_cents: 500, status: 'pending', external_id: 'ext-1')

    expect(dup.valid?).to be_falsey
    expect(dup.errors[:external_id]).to include('has already been taken')
  end
end
