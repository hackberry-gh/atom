class CreateElements < ActiveRecord::Migration
  def change
    create_table :elements, id: :uuid do |t|
      t.json      :meta, null: false, default: {}
      t.integer   :atoms_count, default: 0
      t.timestamps
    end
  end
end