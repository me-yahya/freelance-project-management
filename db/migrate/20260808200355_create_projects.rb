class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :client, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.date :start_date
      t.date :deadline
      t.decimal :budget, precision: 12, scale: 2
      t.string :status, null: false, default: "planned"

      t.timestamps
    end

    add_index :projects, [ :client_id, :status ]
  end
end
