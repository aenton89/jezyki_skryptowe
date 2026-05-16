# frozen_string_literal: true



class Product
  # pozwala na czytanie i pisanie do tych zmiennych spoza klasy (to the best of my knowledge)
  attr_accessor :title, :price, :url, :description

  def initialize(title, price, url = nil)
    @title = title
    @price = price
    @url = url
    @description = nil
  end

  def print_info
    puts "PRODUCT: #{@title}"
    puts "PRICE: #{@price}"
    puts "URL: #{@url}" if @url
    puts "-" * 50
  end

  def print_full_info
    puts "PRODUCT: #{@title}"
    puts "PRICE: #{@price}"
    puts "URL: #{@url}" if @url
    puts "DESCRIPTION: \n#{@description}" if @description
    puts "-" * 50
  end
end