class Recharge < ApplicationRecord
  belongs_to :payment
  
  def self.get_recharge_from_payment(payment)
    response = ::RechargeProviderService.new(payment).process
    response = response.with_indifferent_access
    
    self.create(payment: payment, status: response.dig(:status), error_message: response.dig(:error), provider_reference: response.dig(:provider_reference), external_id: response.dig(:external_id))
  end
end