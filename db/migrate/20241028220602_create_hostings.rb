class CreateHostings < ActiveRecord::Migration[7.2]
  def change
    create_table :hostings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :host, null: false, foreign_key: true

      t.timestamps
    end
  end
end
