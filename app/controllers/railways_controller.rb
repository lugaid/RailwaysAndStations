class RailwaysController < ApplicationController
  before_action :set_railway, only: [:show, :edit, :update, :destroy]

  # GET /railways
  # GET /railways.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: RailwaysDatatable.new(view_context) }
    end
  end

  # GET /railways/1
  # GET /railways/1.json
  def show
  end

  # GET /railways/new
  def new
    @railway = Railway.new
    
    3.times do
      @railway.points.build
    end
  end

  # GET /railways/1/edit
  def edit
  end

  # POST /railways
  # POST /railways.json
  def create
    @railway = Railway.new(railway_params)

    respond_to do |format|
      if @railway.save
        format.html { redirect_to @railway, notice: 'Railway was successfully created.' }
        format.json { render action: 'show', status: :created, location: @railway }
      else
        format.html { render action: 'new' }
        format.json { render json: @railway.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /railways/1
  # PATCH/PUT /railways/1.json
  def update
    respond_to do |format|
      if @railway.update(railway_params)
        format.html { redirect_to @railway, notice: 'Railway was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @railway.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /railways/1
  # DELETE /railways/1.json
  def destroy
    @railway.destroy
    respond_to do |format|
      format.html { redirect_to railways_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_railway
      @railway = Railway.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def railway_params
      params.require(:railway).permit(:name, :abreviation, :description)
    end
end
