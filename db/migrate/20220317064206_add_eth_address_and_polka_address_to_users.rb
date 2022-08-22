class AddEthAddressAndPolkaAddressToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :eth_address, :string, default: '', comment: "ETH address"
    add_column :users, :polka_address, :string, default: '', comment: "Polka address"
    add_column :users, :wallet_type, :string, default: '', comment: "wallet type , e.g. ETH, Polka, BTC"
  end
end
