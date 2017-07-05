class Booking < ApplicationRecord
  include HTTParty

  belongs_to :user
  belongs_to :agent, :class_name => 'User', :foreign_key => 'agent_id'

  # validate :date_cannot_be_in_the_past

  scope :completed, -> { where.not(recipt_number: nil) }
  scope :pending, -> { where(recipt_number: nil).where("ticket_time_limit >= ? OR ticket_time_limit IS ?", Date.today, nil).order("ticket_time_limit ASC") }

  def status
    if ticket_time_limit&.to_date == (Date.today || Date.tomorrow)
      'upcoming'
    elsif ticket_time_limit && ticket_time_limit.to_date < Date.today
      'overdue'
    else
      'normal'
    end
  end

  def date_cannot_be_in_the_past
    if ticket_time_limit.present? && ticket_time_limit < Date.tomorrow
      errors.add(:ticket_time_limit, "can't be in the past")
    end
    if flight_time.present? && flight_time < Date.tomorrow
      errors.add(:flight_time, "can't be in the past")
    end
  end
end
