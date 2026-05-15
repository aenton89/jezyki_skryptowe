# frozen_string_literal: true



class Product
  # pozwala na czytanie i pisanie do tych zmiennych spoza klasy (to the best of my knowledge)
  attr_accessor :title, :price

  def initialize(title, price)
    @title = title
    @price = price
  end

  def print_info
    puts "PRODUCT: #{@title}"
    puts "PRICE: #{@price}"
    puts "-" * 50
  end
end