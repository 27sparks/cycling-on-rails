class User < ActiveRecord::Base

  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, presence:true, length: { minimum: 4 }, allow_nil: true
  has_secure_password

  has_many :activities, :dependent => :destroy

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def max_heart_rate
    185
  end

  def min_heart_rate
    54
  end

  def lactate_threshold
    168
  end

  def distance_total_km date_params = {}
    distance = 0
    activities = activities_for_time_span date_params
    activities.each do |activity|
      distance += activity.distance_km
    end
    distance
  end

  def activities_total date_params = {}
    activities = activities_for_time_span date_params
    activities.count
  end

  def activities_for_time_span date_params = {}
    year = date_params[:year]
    month = date_params[:month]
    case
     when (year.present? && month.nil?) then self.activities.by_year(year)
     when (year.nil? && month.present?) then self.activities.by_month(month)
     when (year.present? && month.present?) then self.activities.by_year_and_month(year, month)
     when (year.nil? && month.nil?) then self.activities.all
     else []
    end
  end

  def admin?
    false
  end
end
