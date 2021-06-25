class ShoppingCart < ApplicationRecord
  acts_as_shopping_cart

  scope :set_user_cart, -> (user) { user_cart = where(user_id: user.id, buy_flag: false)&.last
                               user_cart.nil? ? ShoppingCart.create(user_id: user.id)
                                              : user_cart }
  scope :bought_cart_ids, -> { where(buy_flag: true).pluck(:id) }
+  CARRIAGE=800
+  FREE_SHIPPING=0

  def self.get_monthly_billings
    buy_ids = bought_cart_ids
    return if buy_ids.nil?
    billings = ShoppingCartItem.bought_items(buy_ids).order_updated_at_desc
    hash = Hash.new { |h,k| h[k] = {} }

    billings.each_with_index do |billing,index|
      if index == 0
        hash[billing.updated_at.strftime("%Y-%m")][:quantity_daily] = buy_ids.count
      end
      if hash[billing.updated_at.strftime("%Y-%m")][:price_daily].present?
        hash[billing.updated_at.strftime("%Y-%m")][:price_daily] = hash[billing.updated_at.strftime("%Y-%m")][:price_daily] + billing.price_cents
        hash[billing.updated_at.strftime("%Y-%m")][:price_average_daily] = hash[billing.updated_at.strftime("%Y-%m")][:price_average_daily] + billing.price_cents
      else
        hash[billing.updated_at.strftime("%Y-%m")][:price_daily] = billing.price_cents
        hash[billing.updated_at.strftime("%Y-%m")][:price_average_daily] = billing.price_cents
      end
      if index == billings.size - 1
        hash[billing.updated_at.strftime("%Y-%m")][:price_average_daily] = hash[billing.updated_at.strftime("%Y-%m")][:price_average_daily].to_f / billings.count
      end
    end
    return hash
  end

  def self.get_daily_billings
    buy_ids = bought_cart_ids
    return if buy_ids.nil?
    billings = ShoppingCartItem.bought_items(buy_ids).order_updated_at_desc
    hash = Hash.new { |h,k| h[k] = {} }
 
    billings.each_with_index do |billing,index|
      if index == 0
        hash[billing.updated_at.to_date.to_s][:quantity_daily] = buy_ids.count
      end
      if hash[billing.updated_at.to_date.to_s][:price_daily].present?
        hash[billing.updated_at.to_date.to_s][:price_daily] = hash[billing.updated_at.to_date.to_s][:price_daily] + billing.price_cents
        hash[billing.updated_at.to_date.to_s][:price_average_daily] = hash[billing.updated_at.to_date.to_s][:price_average_daily] + billing.price_cents
      else
        hash[billing.updated_at.to_date.to_s][:price_daily] = billing.price_cents
        hash[billing.updated_at.to_date.to_s][:price_average_daily] = billing.price_cents
      end
      if index == billings.size - 1
        hash[billing.updated_at.to_date.to_s][:price_average_daily] = hash[billing.updated_at.to_date.to_s][:price_average_daily].to_f / billings.count
      end
    end
    return hash
  end


  def tax_pct
    0
  end

  def shipping_cost(cost_flag = {})
    cost_flag.present? ? Money.new(CARRIAGE * 100)
                       : Money.new(FREE_SHIPPING)
  end

  def shipping_cost_check(user)
    cart_id = ShoppingCart.set_user_cart(user)
    product_ids = ShoppingCartItem.keep_item_ids(cart_id)
    check_products_carriage_list = Product.check_products_carriage_list(product_ids)
    check_products_carriage_list.include?("true") ? shipping_cost({cost_flag: true})
                                                  : shipping_cost
  end
end