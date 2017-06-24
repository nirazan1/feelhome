class AddAgentIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :agent_id, :integer
    add_column :users, :agent, :boolean, default: false
    add_column :users, :customer, :boolean, default: true
    add_index :users, :agent_id
  end
end
