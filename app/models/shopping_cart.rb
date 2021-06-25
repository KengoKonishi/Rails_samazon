class ShoppingCart < ApplicationRecord
  acts_as_shopping_cart
  
  scope :set_user_cart, -> (user) { user_cart = where(user_id: user.id, buy_flag: false)&.last
                               user_cart.nil? ? ShoppingCart.create(user_id: user.id)
                                              : user_cart }
  scope :bought_cart_ids, -> { where(buy_flag: true).pluck(:id) }
  scope :sort_list, -> {
    {"日別": "daily", "月別": "month"}
  }

  def self.get_monthly_billings
    buy_ids = bought_cart_ids
    return if buy_ids.nil?
    billings = ShoppingCartItem.bought_items(buy_ids).order_updated_at_desc
    hash = Hash.new { |h,k| h[k] = {} }

    billings.each_with_index do |b,i|
      if i == 0
        hash[b.updated_at.strftime("%Y-%m")][:quantity_daily] = b.quantity
      end
      if hash[b.updated_at.strftime("%Y-%m")][:price_daily].present?
        hash[b.updated_at.strftime("%Y-%m")][:price_daily] = hash[b.updated_at.strftime("%Y-%m")][:price_daily] + b.price_cents
        hash[b.updated_at.strftime("%Y-%m")][:quantity_daily] = hash[b.updated_at.strftime("%Y-%m")][:quantity_daily]  + b.quantity
        hash[b.updated_at.strftime("%Y-%m")][:price_average_daily] = hash[b.updated_at.strftime("%Y-%m")][:price_average_daily] + b.price_cents
      else
        hash[b.updated_at.strftime("%Y-%m")][:price_daily] = b.price_cents
        hash[b.updated_at.strftime("%Y-%m")][:quantity_daily] = b.quantity
        hash[b.updated_at.strftime("%Y-%m")][:price_average_daily] = b.price_cents
      end
      if i == billings.size - 1
        hash[b.updated_at.strftime("%Y-%m")][:price_average_daily] = hash[b.updated_at.strftime("%Y-%m")][:price_average_daily].to_f / billings.count
      end
    end
    return hash
  end

  def self.get_daily_billings
    buy_ids = bought_cart_ids
    return if buy_ids.nil?
    billings = ShoppingCartItem.bought_items(buy_ids).order_updated_at_desc
    hash = Hash.new { |h,k| h[k] = {} }

    billings.each_with_index do |b,i|
      if i == 0
        hash[b.updated_at.to_date.to_s][:quantity_daily] = b.quantity
      end
      if hash[b.updated_at.to_date.to_s][:price_daily].present?
        hash[b.updated_at.to_date.to_s][:price_daily] = hash[b.updated_at.to_date.to_s][:price_daily] + b.price_cents
        hash[b.updated_at.to_date.to_s][:quantity_daily] = hash[b.updated_at.to_date.to_s][:quantity_daily] + b.quantity
        hash[b.updated_at.to_date.to_s][:price_average_daily] = hash[b.updated_at.to_date.to_s][:price_daily].to_f / hash[b.updated_at.to_date.to_s][:quantity_daily]
      else
        hash[b.updated_at.to_date.to_s][:price_daily] = b.price_cents
        hash[b.updated_at.to_date.to_s][:quantity_daily] = b.quantity
        hash[b.updated_at.to_date.to_s][:price_average_daily] = b.price_cents.to_f / hash[b.updated_at.to_date.to_s][:quantity_daily]
      end
    end
    return hash
  end

  def tax_pct
    0
  end
end
