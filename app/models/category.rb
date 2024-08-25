class Category < Sequel::Model
  one_to_many :tests
end