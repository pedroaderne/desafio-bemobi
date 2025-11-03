class Api::V1::PaymentsController < ApplicationController
  wrap_parameters false

  def create
    payment = Payment.create(payment_params)

    if payment.errors.any?
      return render json: payment.errors.full_messages
    end

    if payment.status == "paid"
      recharge = Recharge.create(payment: payment)
    else
      return render json: { error: payment.status }, status: :ok
    end

    if recharge.status.in?([ "success", "failure" ])
      render json: ::RechargeSerializer.new(recharge).as_json, status: :ok
    else
      render json: { error: recharge.status }, status: recharge.code.to_i
    end
  end

  private

  def payment_params
    params.permit(
      :phone_number,
      :amount_in_cents,
      :status,
      :external_id,
      product: [ :id, :amount, :unit, :name ],
      customer: [ :id, :activated_at ],
      payment_source: [ :type, :wallet ]
    ).to_h
  end
end
