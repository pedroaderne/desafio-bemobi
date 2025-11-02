class Api::V1::PaymentsController < ApplicationController
  wrap_parameters false
  
  def create
    payment = Payment.create(payment_params)
	
    if payment.errors.any?
      return render json: payment.errors.full_messages
    end
    
    if payment.status == 'paid'
      recharge = Recharge.get_recharge_from_payment(payment)
    else
      recharge = Recharge.create!(payment: payment, status: 'failed', error_message: 'Payment failed', provider_reference: nil, external_id: nil)
    end

    if recharge.status.in?(['success', 'failed'])
      status_code = 200
    else
      status_code = recharge.status.to_i
    end
    
    render json: recharge, status: status_code
  end
  
  private
  def payment_params
    params.permit(
      :phone_number,
      :amount_in_cents,
      :status,
      :external_id,
      product: [ :id, :amount, :unit ],
      customer: [:id, :activated_at],
      payment_source: [:id, :name, :amount, :unit]
    ).to_h
  end
end