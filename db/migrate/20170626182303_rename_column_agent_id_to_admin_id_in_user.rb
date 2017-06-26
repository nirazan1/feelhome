class RenameColumnAgentIdToAdminIdInUser < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :agent_id
    add_column :users, :admin, :boolean, default: false
  end
end
