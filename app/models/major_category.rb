class MajorCategory < ApplicationRecord
  has_many :categories
  extend DisplayList
end
