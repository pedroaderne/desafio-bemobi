class RechargeSerializer
  include JSONAPI::Serializer

  attributes :id, :status, :error_message, :provider_reference, :external_id
end
