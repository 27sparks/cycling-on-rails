class StatisticsController < ApplicationController
  include StatisticsHelper

  LOAD_PERCENTAGE_ARRAY = [1,5,10,15,30,40,43,45,47,49,50,49,48,46,44,42,40,37,35,34,32,31,29,28,24,20,17,14,12,10,9,8,7,6,5,4,3,2,1]
  FATIQUE_PERCENTAGE_ARRAY = [100,80,50,40,30,20,10,5,3,2,1]

  def index
    activities = current_user.activities.all
    @results = get_prepared_object params[:year]
    activities.each do |activity|
      day = activity.start_time.to_date.yday
      # add fatigue to the results
      FATIQUE_PERCENTAGE_ARRAY.each_with_index do |percent, i|
        if @results[:fatique][:data][day + i].nil? == false
          @results[:fatique][:data][day + i] += (activity.trimp / 100 * percent).to_f
        end
      end
      #add load to the results
      LOAD_PERCENTAGE_ARRAY.each_with_index do |percent, i|
        if @results[:load][:data][day + i].nil? == false
          @results[:load][:data][day + i] += (activity.trimp / 100 * percent).to_f
        end
      end
      #add average heartrate to the results
      @results[:avghr][:data][day] = activity.avghr_bpm.to_f
      @results[:trimp][:data][day] = activity.trimp.to_f
      @results[:distance][:data][day] = activity.distance_m.to_f
      @results[:duration][:data][day] = activity.duration_h.to_f

    end
    @results[:avghr][:unit] = 'bpm'
    @results[:avghr][:type] = 'bar'
    @results[:avghr][:name] = 'bpm'
    @results[:trimp][:unit] = 'imp'
    @results[:trimp][:type] = 'bar'
    @results[:trimp][:name] = 'trimp'
    @results[:distance][:unit] = 'm'
    @results[:distance][:type] = 'bar'
    @results[:distance][:name] = 'distance'
    @results[:duration][:unit] = 'h'
    @results[:duration][:type] = 'bar'
    @results[:duration][:name] = 'duration'
    @results[:fatique][:unit] = 'fatique'
    @results[:fatique][:type] = 'line'
    @results[:fatique][:name] = 'fatique'
    @results[:load][:unit] = 'load'
    @results[:load][:type] = 'areaspline'
    @results[:load][:name] = 'load'
    @results.each do |key, result|
      @results[key][:pointStart] = get_point_start('year', '1-1-2015')
      @results[key][:pointInterval] = get_point_interval('by_days')
    end
  end

  # GET /statistics/1
  # GET /statistics/1.json
  def show
    activity = Activity.find(params[:id])
    last_distance = 0
    @result = {}

    @result[:hrbpm] = {}
    @result[:hrbpm][:unit] = 'bpm'
    @result[:hrbpm][:name] = 'heartrate'
    @result[:hrbpm][:type] = 'spline'

    @result[:alt] = {}
    @result[:alt][:type] = 'areaspline'
    @result[:alt][:unit] = 'm'
    @result[:alt][:name] = 'height'

    @result[:speed] = {}
    @result[:speed][:unit] = 'km/h'
    @result[:speed][:name] = 'speed'
    @result[:speed][:type] = 'spline'

    @result.each do |key, value|
      @result[key][:data] = []
      @result[key][:pointStart] = activity.start_time.to_datetime.strftime('%Q').to_i
      @result[key][:pointInterval] = 1000
    end
    activity.laps.order(:start_time).each do |lap|
      lap.track.track_points.order(:time).each do |point|
        @result[:hrbpm][:data] << [ point.distance_meters.to_f,point.heart_rate_bpm.to_i]
        @result[:alt][:data] << [ point.distance_meters.to_f,point.altitude_meters.to_f]
        if point.distance_meters.present?
          speed = (point.distance_meters - last_distance) * 3.6
        end
        @result[:speed][:data] << [point.distance_meters.to_f, speed.to_f]
        last_distance =  point.distance_meters.to_f
      end
    end
    @result[:start_time] = activity.start_time.to_datetime
    @result[:end_time] = activity.start_time.to_datetime + activity.duration_s.seconds
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
