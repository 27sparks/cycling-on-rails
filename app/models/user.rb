class User < ActiveRecord::Base

  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, presence:true, length: { minimum: 4 }, allow_nil: true
  has_secure_password

  has_many :activities

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def distance_total_km year = nil, month = nil
    distance = 0
    activities = case
                   when (year.present? && month.nil?) then self.activities.by_year(year)
                   when (year.nil? && month.present?) then self.activities.by_month(month)
                   when (year.present? && month.present?) then self.activities.by_year_and_month(year, month)
                   when (year.nil? && month.nil?) then self.activities.all
                   else []

    end
    activities.each do |activity|
      distance += activity.distance_total_km
    end
    distance
  end

end
