class ArtsController < ApplicationController
  before_action :set_art, only: [:show, :edit, :update, :destroy]
  before_action :kristin_and_forrest_only, only: [:love, :create_love_message]
  before_action :arts, only: [:paper, :bands, :love]

  def get_distance
    @coords = if currently_kristin?
      eval User.first.geo_coordinates
    elsif god? and not in_dev?
      eval User.find(34).geo_coordinates
    # for testing in development, just the same coords
    elsif in_dev?
      [params[:lat], params[:long]]
    end

    current_location = Geokit::LatLng.new(@coords[0], @coords[1])
    destination = "#{params[:lat]},#{params[:long]}"

    # gets distance in miles, rounds to 5th decimal place
    @distance = current_location.distance_to(destination).round(5).to_s
    puts "\n" + @distance + "\n"

  end

  def paper
    @paper = true
  end

  def create_love_message
  end

  def bands
    @bands = true
  end

  def love
    @love = true
    @message = Message.new
  end

  # GET /arts
  # GET /arts.json
  def index
    @arts = Art.all
  end

  # GET /arts/1
  # GET /arts/1.json
  def show
  end

  # GET /arts/new
  def new
    @art = Art.new
  end

  # GET /arts/1/edit
  def edit
  end

  # POST /arts
  # POST /arts.json
  def create
    @art = Art.new(art_params)

    respond_to do |format|
      if @art.save
        format.html { redirect_to @art, notice: 'Art was successfully created.' }
        format.json { render :show, status: :created, location: @art }
      else
        format.html { render :new }
        format.json { render json: @art.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /arts/1
  # PATCH/PUT /arts/1.json
  def update
    respond_to do |format|
      if @art.update(art_params)
        format.html { redirect_to @art, notice: 'Art was successfully updated.' }
        format.json { render :show, status: :ok, location: @art }
      else
        format.html { render :edit }
        format.json { render json: @art.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arts/1
  # DELETE /arts/1.json
  def destroy
    @art.destroy
    respond_to do |format|
      format.html { redirect_to arts_url, notice: 'Art was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def arts
    @arts = true
  end

  def kristin_and_forrest_only
    unless currently_kristin? or god?
      redirect_to '/404' unless Rails.env.development?
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_art
    @art = Art.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def art_params
    params.fetch(:art, {})
  end
end
