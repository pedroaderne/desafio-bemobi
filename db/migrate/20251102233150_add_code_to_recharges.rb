class AddCodeToRecharges < ActiveRecord::Migration[8.1]
  def change
    add_column :recharges, :code, :integer
  end
end
