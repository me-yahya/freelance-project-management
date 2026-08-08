class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.date :due_date
      t.string :priority, null: false, default: "medium"
      t.string :status, null: false, default: "to_do"

      t.timestamps
    end

    add_index :tasks, [ :project_id, :status ]
    add_index :tasks, [ :project_id, :due_date ]
  end
end
