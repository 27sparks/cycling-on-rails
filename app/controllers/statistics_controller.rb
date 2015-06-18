class StatisticsController < ApplicationController
  before_action :set_statistic, only: [:show, :edit, :update, :destroy]
  def index
    function_call = "#{params[:values]}_#{params[:unit]}".to_sym
    interval = Statistic.prepare_interval params[:time_frame], params[:date]
    activities = current_user.activities.where("start_time >= ? and start_time <= ?", interval[:start], interval[:end])
    @results = Statistic.get_prepared_array_for params[:time_frame], params[:date], params[:steps]

    activities.each do |activity|
      case
        when params[:time_frame] == 'year' && params[:steps] == 'by_weeks'
          @results[activity.start_time.to_date.cweek][:value] += activity.send function_call
        when params[:time_frame] == 'year' && params[:steps] == 'by_days'
          @results[activity.start_time.to_date.yday][:value] += activity.send function_call
        when params[:time_frame] == 'month'
          @results[activity.start_time.to_date.day][:value] += activity.send function_call
        else
          @results[activity.start_time.month - 1][:value] += activity.send function_call
      end
    end
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
