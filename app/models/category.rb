class Category < ApplicationRecord
    belongs_to :major_category
    has_many :products, dependent: :destroy
    
    extend DisplayList
    scope :major_categories, -> { pluck(:major_category_name).uniq }
    scope :request_category, -> (category) { find(category.to_i) }
end
