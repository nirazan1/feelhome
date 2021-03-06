class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true,
            length: { minimum: 5 }
  validates :contact_number, presence: true,
            length: { minimum: 7 }, numericality: true
  validates :email, presence: true,
                    length: { minimum: 2 }, uniqueness: { case_sensitive: false }

  has_many :user_bookings, :class_name => 'Booking', :foreign_key => 'user_id'
  has_many :agent_bookings, :class_name => 'Booking', :foreign_key => 'agent_id'

  def self.default_agent
    User.first
  end

  def name_email
    "#{name} [ ☎#{contact_number} ]"
  end

  private
  def password_required?
    new_record? ? super : false
  end
end
