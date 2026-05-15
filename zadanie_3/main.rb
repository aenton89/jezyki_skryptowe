# frozen_string_literal: true

require_relative 'crawler'

crawler = Crawler.new
products = crawler.fetch_products

if products.empty?
  puts "no products found"
else
  products.first(5).each do |product|
    product.print_info
  end
end