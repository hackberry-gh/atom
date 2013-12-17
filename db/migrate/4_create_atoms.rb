class CreateAtoms < ActiveRecord::Migration
  def change
    
    create_table :atoms, id: false do |t|
      t.uuid      :id, null: false, default: "uuid_generate_v4()"
      t.uuid      :element_id, null: false
      t.json      :data, default: {}
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX atoms_unique_id ON atoms(id, element_id);"
    execute "ALTER TABLE atoms ADD PRIMARY KEY (id, element_id);"
  end
end