class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :agent, :class_name => 'User', :foreign_key => 'agent_id'
end
