module StatisticsHelper
  def get_point_start time_frame, date
    case time_frame
      when 'week'
        get_date_from_anything(date).beginning_of_week.to_datetime.strftime('%Q').to_i
      when 'month'
        get_date_from_anything(date).beginning_of_month.to_datetime.strftime('%Q').to_i
      else
        get_date_from_anything(date).beginning_of_year.to_datetime.strftime('%Q').to_i
    end
  end

  def get_point_interval steps
    case steps
      when 'by_days'
        1.day * 1000
      when 'by_weeks'
        1.week * 1000
      else
        1.month * 1000
    end
  end

  def get_date_from_anything date
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

  def get_function_call requested_values, unit
    "#{requested_values}_#{unit}".to_sym
  end

  def prepare_interval time_frame = 'year', date, values_requested
    request_date = get_date_from_anything date
    interval =  case time_frame
                  when 'year' then { start: request_date.beginning_of_year, end: request_date.end_of_year }
                  when 'month' then { start: request_date.beginning_of_month, end: request_date.end_of_month }
                end
    if values_requested == 'fatique'
      interval[:start] -= 30.days
    end
    interval
  end

  def get_prepared_object_for time_frame, date, steps
    data_array =  case
                    when time_frame == 'year' && steps == 'by_weeks'
                      year_by_weeks_array date
                    when time_frame == 'year' && steps == 'by_days'
                      year_by_days_array date
                    when time_frame == 'month'
                      month_by_days_array date
                    else
                      year_by_months_array
                  end
    { data: data_array }
  end

  def year_by_months_array
    Array.new(12, 0)
  end

  def year_by_weeks_array date
    year = get_date_from_anything(date).year
    number_of_weeks = Date.new(year, 12, 28).cweek
    Array.new(number_of_weeks, 0)
  end

  def year_by_days_array date
    year = get_date_from_anything(date).year
    number_of_days = Date.new(year, 12, 31).yday
    Array.new(number_of_days, 0)
  end

  def month_by_days_array date
    date = get_date_from_anything(date)
    number_of_days = Time.days_in_month(date.month, date.year)
    Array.new(number_of_days, 0)
  end
end
