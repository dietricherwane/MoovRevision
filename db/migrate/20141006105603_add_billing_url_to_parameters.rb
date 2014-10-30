class AddBillingUrlToParameters < ActiveRecord::Migration
  def change
    add_column :parameters, :billing_url, :string
  end
end
