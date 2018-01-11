class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :invite_only
  
  def add_image
  end

  # GET /products
  # GET /products.json
  def index
    @product = Product.new
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        # checks for image upload
        if params[:pictures]
          # builds photoset for product
          params[:pictures][:image].each do |image|
            @product.pictures.create image: image
          end
        end
        
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def invite_only
    unless invited?
      redirect_to invite_only_path
    end
  end
  
  # Use callbacks to share common setup or constraints between actions.
  def set_product
    if params[:token]
      @product = Product.find_by_unique_token(params[:token])
      @product ||= Product.find_by_id(params[:token])
    else
      @product = Product.find_by_id(params[:id])
      @product ||= Product.find_by_unique_token(params[:id])
    end
    redirect_to '/404' unless @product
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.fetch(:product, {}).permit(:name, :description, :body, :image, :price,
      pictures_attributes: [:id, :product_id, :image])
  end
end
