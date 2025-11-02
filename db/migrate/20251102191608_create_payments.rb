class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.string :phone_number
      t.integer :amount_in_cents
      t.string :status
      t.string :external_id
      t.json :product
      t.json :customer
      t.json :payment_source

      t.timestamps
    end
  end
end
