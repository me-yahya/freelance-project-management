class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :company
      t.string :email
      t.string :phone
      t.text :address
      t.text :notes

      t.timestamps
    end

    add_index :clients, [ :user_id, :name ]
  end
end
