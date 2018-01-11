class WishListsController < ApplicationController
  before_action :set_wish_list, only: [:show, :edit, :update, :destroy]
  before_action :set_product, only: [:add_to_wish_list, :remove_from_wish_list]
  before_action :invite_only
  
  def my_wish_list
    @wish_list = current_user.my_wish_list
    @products = @wish_list.products
  end
  
  def add_to_wish_list
    current_user.my_wish_list.add @product if @product
  end
  
  def remove_from_wish_list
    current_user.my_wish_list.remove @product if @product
  end

  # GET /wish_lists
  # GET /wish_lists.json
  def index
    @wish_lists = WishList.all
  end

  # GET /wish_lists/1
  # GET /wish_lists/1.json
  def show
  end

  # GET /wish_lists/new
  def new
    @wish_list = WishList.new
  end

  # GET /wish_lists/1/edit
  def edit
  end

  # POST /wish_lists
  # POST /wish_lists.json
  def create
    @wish_list = WishList.new(wish_list_params)

    respond_to do |format|
      if @wish_list.save
        format.html { redirect_to @wish_list, notice: 'Wish list was successfully created.' }
        format.json { render :show, status: :created, location: @wish_list }
      else
        format.html { render :new }
        format.json { render json: @wish_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wish_lists/1
  # PATCH/PUT /wish_lists/1.json
  def update
    respond_to do |format|
      if @wish_list.update(wish_list_params)
        format.html { redirect_to @wish_list, notice: 'Wish list was successfully updated.' }
        format.json { render :show, status: :ok, location: @wish_list }
      else
        format.html { render :edit }
        format.json { render json: @wish_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wish_lists/1
  # DELETE /wish_lists/1.json
  def destroy
    @wish_list.destroy
    respond_to do |format|
      format.html { redirect_to wish_lists_url, notice: 'Wish list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def invite_only
    unless invited?
      redirect_to invite_only_path
    end
  end
  
  def set_product
    @product = Product.find_by_unique_token params[:token]
  end
  
  # Use callbacks to share common setup or constraints between actions.
  def set_wish_list
    @wish_list = WishList.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def wish_list_params
    params.fetch(:wish_list, {})
  end
end
