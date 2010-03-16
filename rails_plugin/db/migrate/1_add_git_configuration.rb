
class AddGitConfiguration < ActiveRecord::Migration
  
  def self.up
    create_table :git_configurations, :force => true do |t|
      t.column(:project_id, :integer)
      t.column(:repository_path, :string)
      t.column(:username, :string)
      t.column(:password, :string)
      t.column(:initialized, :boolean)
      t.column(:card_revision_links_invalid, :boolean)
      t.column(:marked_for_deletion, :boolean, :default => false)
    end
  end

  def self.down
    drop_table :git_configurations
  end
end

