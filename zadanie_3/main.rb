# frozen_string_literal: true

require_relative 'crawler'
require_relative 'storage_txt'



def run_search
  puts "provide keyword:"
  keyword = gets.chomp

  crawler = Crawler.new
  products = crawler.fetch_products(keyword)

  StorageTXT.save_products(products, keyword)

  if products.empty?
    puts "no products found"
    return
  end

  index = 0
  page_size = 5

  loop do
    puts "\nshowing products #{index + 1} - #{[index + page_size, products.size].min}"
    puts "-" * 80

    products[index, page_size].each do |product|
      product.print_info
    end

    puts "\n[n] next 5 | [r] new search | [q] quit"
    puts "[number] to get this product's details"
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

    # wpisanie numeru pobiera szczegóły wybranego produktu
    elsif input =~ /^\d+$/
      chosen_index = input.to_i - 1
      product = products[chosen_index]

      if product.nil?
        puts "invalid input"
        next
      end

      crawler.fetch_details(product)
      product.print_full_info
      puts "\n[enter] go back to list"
      # czekaj aż wciśnie
      gets
    end
  end
end



run_search