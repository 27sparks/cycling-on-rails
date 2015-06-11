class Statistic < ActiveRecord::Base
  belongs_to :user

  def self.prepare_interval time_frame = 'year', date
    request_date = self.get_date_from_anything date
    case time_frame
      when 'year' then { start: request_date.beginning_of_year, end: request_date.end_of_year }
      when 'month' then { start: request_date.beginning_of_month, end: request_date.end_of_month }
    end
  end

  def self.get_prepared_array_for time_frame, date, steps
    case
      when time_frame == 'year' && steps == 'by_weeks'
        Statistic.year_by_weeks_array date
      when time_frame == 'year' && steps == 'by_days'
        Statistic.year_by_days_array date
      when time_frame == 'month'
        Statistic.month_by_days_array date
      else
        self.year_by_months_array
    end
  end

  def self.year_by_months_array
    Date::MONTHNAMES.map { |name| { value: 0, name: name} }
  end

  def self.year_by_weeks_array date
    year = get_date_from_anything(date).year
    number_of_weeks = Date.new(year, 12, 28).cweek
    (1..number_of_weeks).map { |index| { value: 0, name: index } }
  end

  def self.year_by_days_array date
    year = get_date_from_anything(date).year
    number_of_days = Date.new(year, 12, 31).yday
    (1..number_of_days).map { |index| { value: 0, name: index } }
  end

  def self.month_by_days_array date
    date = get_date_from_anything(date)
    number_of_days = Time.days_in_month(date.month, date.year)
    (1..number_of_days).map { |index| { value: 0, name: index } }
  end

  def self.get_date_from_anything date
    if date.present?
      case
        when date.include?('-') then DateTime.parse(date)
        when date.length == 2 then Date.new(('20' + date).to_i)
        else Date.new(date.to_i)
      end
    else
      Date.today
    end
  end
end
