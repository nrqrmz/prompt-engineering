class Challenge < ApplicationRecord
  validates :name, :module, :content, presence: true
end
