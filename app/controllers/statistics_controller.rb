class StatisticsController < ApplicationController
  include StatisticsHelper
  before_action :set_statistic, only: [:show, :edit, :update, :destroy]

  def index
    function_call = get_function_call params[:values], params[:unit]
    interval = prepare_interval params[:time_frame], params[:date], params[:values]
    activities = current_user.activities.where("start_time >= ? and start_time <= ?", interval[:start], interval[:end])
    @results = get_prepared_object_for params[:time_frame], params[:date], params[:steps]

    case params[:values]
      when 'fatigue'
        activities.each do |activity|
          case params[:time_frame]
            when 'month'
              (1..100).each do |i|
                if @results[:data][activity.start_time.to_date.day + i - 1].nil? == false
                  @results[:data][activity.start_time.to_date.day + i - 1] += ((activity.trimp / 50 / i) * 30.0).to_f
                end
              end
            else
              (1..100).each do |i|
                if @results[:data][activity.start_time.to_date.yday + i- 1].nil? == false
                  @results[:data][activity.start_time.to_date.yday + i - 1] += ((activity.trimp / 50 / i) * 20.0).to_f
                end
              end
          end

        end
      when 'load'
        activities.each do |activity|
          case params[:time_frame]
            when 'month'
              (1..6).each do |i|
                @results[:data][activity.start_time.to_date.day + i] += i if @results[:data][activity.start_time.to_date.day + i].present?
              end
              (7..100).each do |i|
                @results[:data][activity.start_time.to_date.day + i] += 6.0 if @results[:data][activity.start_time.to_date.day + i].present?
              end
              (2..6).each do |i|
                @results[:data][activity.start_time.to_date.day + i] -= ((activity.trimp / 200 / i) * 10.0).to_f if @results[:data][activity.start_time.to_date.day + i].present?
              end
              (7..100).each do |i|
                @results[:data][activity.start_time.to_date.day + i] -= (i.to_f / 16) if @results[:data][activity.start_time.to_date.day + i].present?
              end
            else
              (1..6).each do |i|
                @results[:data][activity.start_time.to_date.yday + i] += i if @results[:data][activity.start_time.to_date.yday + i].present?
              end
              (7..100).each do |i|
                @results[:data][activity.start_time.to_date.yday + i] += 6.0 if @results[:data][activity.start_time.to_date.yday + i].present?
              end
              (2..6).each do |i|
                @results[:data][activity.start_time.to_date.yday + i] -= ((activity.trimp / 200 / i) * 10.0).to_f if @results[:data][activity.start_time.to_date.yday + i].present?
              end
              (7..100).each do |i|
                @results[:data][activity.start_time.to_date.yday + i] -= (i.to_f / 16) if @results[:data][activity.start_time.to_date.yday + i].present?
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
  end

  # GET /statistics/new
  def new
    @statistic = Statistic.new
  end

  # GET /statistics/1/edit
  def edit
  end

  # POST /statistics
  # POST /statistics.json
  def create
    @statistic = Statistic.new(statistic_params)

    respond_to do |format|
      if @statistic.save
        format.html { redirect_to @statistic, notice: 'Statistic was successfully created.' }
        format.json { render :show, status: :created, location: @statistic }
      else
        format.html { render :new }
        format.json { render json: @statistic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /statistics/1
  # PATCH/PUT /statistics/1.json
  def update
    respond_to do |format|
      if @statistic.update(statistic_params)
        format.html { redirect_to @statistic, notice: 'Statistic was successfully updated.' }
        format.json { render :show, status: :ok, location: @statistic }
      else
        format.html { render :edit }
        format.json { render json: @statistic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statistics/1
  # DELETE /statistics/1.json
  def destroy
    @statistic.destroy
    respond_to do |format|
      format.html { redirect_to statistics_url, notice: 'Statistic was successfully destroyed.' }
      format.json { head :no_content }
    end
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
