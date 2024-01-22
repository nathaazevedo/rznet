class Post < ApplicationRecord
  belongs_to :author

  validates :title, presence: true
  validates :content, length: { minimum: 100 }
  validates :category, presence: true
end
