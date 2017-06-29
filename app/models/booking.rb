class Booking < ApplicationRecord
  include HTTParty

  belongs_to :user
  belongs_to :agent, :class_name => 'User', :foreign_key => 'agent_id'

  validate :date_cannot_be_in_the_past
  validates :airline, :origin, :destination, :flight_time,
             :ticket_time_limit, :ticket_number, :bill_number,
             :ticket_type, :flght_number, :pnr, :currency, :amount,
             :presence => {:message => "can't be empty"}


  scope :completed, -> { where.not(recipt_number: nil) }
  scope :pending, -> { where(recipt_number: nil).where("ticket_time_limit >= ?", Date.today).order("ticket_time_limit ASC") }

  def status
    if ticket_time_limit.to_date == (Date.today || Date.tomorrow)
      'upcoming'
    elsif ticket_time_limit.to_date < Date.today
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
