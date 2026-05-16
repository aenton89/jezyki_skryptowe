# frozen_string_literal: true

require_relative 'crawler'



def run_search
  puts "provide keyword:"
  keyword = gets.chomp

  crawler = Crawler.new
  products = crawler.fetch_products(keyword)

  if products.empty?
    puts "no products found"
    nil
  end

  index = 0
  page_size = 5

  loop do
    puts "showing products #{index + 1} - #{[index + page_size, products.size].min}"
    puts "-" * 50

    products[index, page_size].each do |product|
      product.print_info
    end

    puts "-" * 50
    puts "[n] next 5 | [r] new search | [q] quit"
    input = gets.chomp.downcase

    if input == "n"
      index += page_size
      if index >= products.size
        puts "no more products found"
        exit
      end
    elsif input == "r"
      return run_search
    elsif input == "q"
      exit
    end
  end
end



run_search