class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :agent, :class_name => 'User', :foreign_key => 'agent_id'

  scope :completed, -> { where.not(recipt_number: nil) }
  scope :pending, -> { where(recipt_number: nil).where("ticket_time_limit >= ?", Date.today).order("ticket_time_limit ASC") }
end
