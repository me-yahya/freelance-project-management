class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :project, null: false, foreign_key: true
      t.string :invoice_number, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.date :issue_date
      t.date :due_date
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    add_index :invoices, [ :project_id, :invoice_number ], unique: true
    add_index :invoices, [ :project_id, :status ]
  end
end
