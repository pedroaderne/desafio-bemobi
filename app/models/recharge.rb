class Recharge < ApplicationRecord
  belongs_to :payment
  before_create :send_to_provider

  def send_to_provider
    response = ::RechargeProviderService.new(self.payment).process
    response = response.with_indifferent_access

    self.code = response[:code]
    self.status = response[:status]
    self.error_message = response[:error]
    self.provider_reference = response[:provider_reference]
    self.external_id = response[:external_id]
  end
end
