class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :title
      t.string :tagline
      t.text :description
      t.text :postscript
      t.datetime :starts
      t.string :ends
      t.string :location

      t.timestamps
    end
  end
end
