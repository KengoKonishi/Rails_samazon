class Dashboard::ProductsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_product, only: %w[show edit update destroy]
  layout "dashboard/dashboard"

  def index
    sort_query = []
    @sorted = ""

    if params[:sort].present?
      slices = params[:sort].split(' ')
      sort_query[slices[0]] = slices[1]
      @sorted = params[:sort]
    end

    if params[:keyword] != nil
      keyword = trim(params[:keyword])
      @total_count = Product.search_for_id_and_name(keyword).count
      @products = Product.search_for_id_and_name(keyword).sort_order(sort_query).display_list(params[:pages])
    else
      keyword = ""
      @total_count = Product.count
      @products = Product.display_list(params[:page])
    end

    @sort_list = Product.sort_list

  end

  def new
    @categories = Category.all
  end

  def create
    product = Product.new(product_params)
    product.save
    redirect_to _pathdashboard_products
  end

  def edit
    @categories = Category.all
  end

  def update
    @product.update(product_params)
    redirect_to dashboard_products_path
  end

  def destroy
    @product.destroy
    redirect_to dashboard_products_path
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :price, :recommended_flag, :category_id)
    end
end
