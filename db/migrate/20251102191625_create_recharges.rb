class CreateRecharges < ActiveRecord::Migration[8.1]
  def change
    create_table :recharges do |t|
      t.references :payment, null: false, foreign_key: true
      t.string :status
      t.string :provider_reference
      t.string :error_message
      t.string :external_id

      t.timestamps
    end
  end
end
