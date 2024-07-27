class CreateRoles < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :roles, id: :uuid do |t|
      t.string :name, null: false, index: { unique: true }
      t.boolean :is_default, null: false, default: false, index: true

      t.timestamps
    end
  end
end
