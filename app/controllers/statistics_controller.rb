class StatisticsController < ApplicationController
  include StatisticsHelper

  LOAD_PERCENTAGE_ARRAY = [1,5,10,15,30,40,43,45,47,49,50,49,48,46,44,42,40,37,35,34,32,31,29,28,24,20,17,14,12,10,9,8,7,6,5,4,3,2,1]
  FATIGUE_PERCENTAGE_ARRAY = [100,80,50,40,30,20,10,5,3,2,1]

  def index
    function_call = get_function_call params[:values], params[:unit]
    interval = prepare_interval params[:time_frame], params[:date], params[:values]
    activities = current_user.activities.where("start_time >= ? and start_time <= ?", interval[:start], interval[:end])
    @results = get_prepared_object_for params[:time_frame], params[:date], params[:steps]

    case params[:values]
      when 'fatigue'
        activities.each do |activity|
          day = params[:time_frame] == 'month' ? activity.start_time.to_date.day : activity.start_time.to_date.yday
          FATIGUE_PERCENTAGE_ARRAY.each_with_index do |percent, i|
            if @results[:data][day + i].nil? == false
              @results[:data][day + i] += (activity.trimp / 100 * percent).to_f
            end
          end
        end
      when 'load'
        activities.each do |activity|
          day = params[:time_frame] == 'month' ? activity.start_time.to_date.day : activity.start_time.to_date.yday
          LOAD_PERCENTAGE_ARRAY.each_with_index do |percent, i|
            if @results[:data][day + i].nil? == false
              @results[:data][day + i] += (activity.trimp / 100 * percent).to_f
            end
          end
        end

      when 'avghr'
        activities.each do |activity|
          case
            when params[:time_frame] == 'year' && params[:steps] == 'by_weeks'
              @results[:data][activity.start_time.to_date.cweek - 1] += activity.send(function_call).to_f
            when params[:time_frame] == 'year' && params[:steps] == 'by_days'
              if activity.send(function_call).to_f > @results[:data][activity.start_time.to_date.yday - 1]
                @results[:data][activity.start_time.to_date.yday - 1] = activity.send(function_call).to_f
              end
            when params[:time_frame] == 'month'
              @results[:data][activity.start_time.to_date.day - 1] += activity.send(function_call).to_f
            else
              @results[:data][activity.start_time.month - 1] += activity.send(function_call).to_f
          end
        end
      else
        activities.each do |activity|
          case
            when params[:time_frame] == 'year' && params[:steps] == 'by_weeks'
              @results[:data][activity.start_time.to_date.cweek - 1] += activity.send(function_call).to_f
            when params[:time_frame] == 'year' && params[:steps] == 'by_days'
              @results[:data][activity.start_time.to_date.yday - 1] += activity.send(function_call).to_f
            when params[:time_frame] == 'month'
              @results[:data][activity.start_time.to_date.day - 1] += activity.send(function_call).to_f
            else
              @results[:data][activity.start_time.month - 1] += activity.send(function_call).to_f
          end
        end
    end
    @results[:type] = case params[:unit]
                        when 'no_unit'
                          'line'
                        when 'imp', 'bpm', 'km', 'h'
                          'bar'
                        when 'load'
                          'areaspline'
                        else
                          'spline'
                      end
    @results[:pointStart] = get_point_start params[:time_frame], params[:date]
    @results[:pointInterval] = get_point_interval params[:steps]
  end

  # GET /statistics/1
  # GET /statistics/1.json
  def show
    activity = Activity.find(params[:id])
    @result = {}
    @result[:hrbpm] = []
    @result[:alt] = []
    @result[:distance] = []
    activity.laps.each do |lap|
      lap.track.track_points.each do |point|
        @result[:hrbpm] << point.heart_rate_bpm
        @result[:alt] << point.altitude_meters
        @result[:distance] << point.distance_meters
      end
    end
    @result[:pointStart] = 0
    @result[:pointInterval] = 1000
    @result
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_statistic
      @statistic = Statistic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def statistic_params
      params.require(:statistic).permit(:user_id)
    end

end
