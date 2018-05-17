class AddContactRequestsTable < ActiveRecord::Migration
  def change
    create_table :contact_requests do |t|
      t.integer  :whois_record_id, null: false
      t.string   :secret,          null: false
      t.string   :email,           null: false
      t.datetime :valid_to,        null: false
      t.string   :status,          null: false, default: 'new'

      t.timestamps
    end

    add_foreign_key :contact_requests, :whois_records
    add_index :contact_requests, :secret, unique: true
    add_index :contact_requests, :email
    add_index :contact_requests, :whois_record_id
  end
end
