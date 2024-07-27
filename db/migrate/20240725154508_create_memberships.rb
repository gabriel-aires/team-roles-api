class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.uuid :team_id, null: false
      t.references :role, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    # allow membership lookup using conditions in any order
    add_index :memberships, [:user_id, :team_id]
    add_index :memberships, [:team_id, :user_id]
  end
end
