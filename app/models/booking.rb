class Booking < ApplicationRecord
  include HTTParty

  belongs_to :user
  belongs_to :agent, :class_name => 'User', :foreign_key => 'agent_id'

  # validate :date_cannot_be_in_the_past

  scope :completed, -> { where("ticket_number <> ''") }
  # scope :pending, -> { where(ticket_number: nil).where("ticket_time_limit >= ? OR ticket_time_limit IS ?", Date.today, nil).order("ticket_time_limit ASC") }
  scope :payment_due, -> { where("recipt_number <> ''") }
  scope :pending, -> { where.not("ticket_number <> ''") }


  def status
    if ticket_number.present?
      'completed'
    elsif ticket_time_limit && ticket_time_limit.to_time < Time.current + 9.hours
      'upcoming'
    elsif ticket_time_limit && ticket_time_limit.to_time < Time.current + 3.hours
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
