require "httparty"

class RechargeProviderService
  include HTTParty

  def initialize(payment)
    @payment = payment
  end

  def process
    # Preparar o payload para a requisição ao provedor
    payload = {
      product_id: @payment.product.with_indifferent_access.dig(:id),
      phone_number: @payment.phone_number,
      amount: @payment.product.with_indifferent_access.dig(:amount),
      unit: @payment.product.with_indifferent_access.dig(:unit),
      external_id: @payment.external_id,
      customer_id: @payment.customer.with_indifferent_access.dig(:id)
    }

    # Chamar o provedor de recarga
    begin
      response = HTTParty.post("https://topup-platform-product-provider.onrender.com/provider/topup", body: payload.to_json, headers: { "Content-Type" => "application/json" })

      parse_provider_response(response)
    rescue Net::OpenTimeout
      { status: "failed", error_message: "Timeout", provider_reference: nil }
    rescue => e
      { status: "failed", error_message: e.message, provider_reference: nil }
    end
  end

  private

  def parse_provider_response(response)
    body = JSON.parse(response.body).with_indifferent_access
    if response.code == 200
      { code: response.code, status: body.dig(:status), provider_reference: body.dig(:provider_reference), error_message: nil, external_id: body.dig(:external_id) }
    else
      { code: response.code, status: body.dig(:error), error_message: body.dig(:error), provider_reference: body.dig(:provider_reference), external_id: body.dig(:external_id) }
    end
  end
end
