# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

require_relative 'product'



class Crawler
  BASE_URL = "https://www.amazon.pl/s?k="

  def initialize
    @headers = {
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36",
    }
  end

  def fetch_products(keyword = "laptop ideapad 3")
    url = BASE_URL + URI.encode_www_form_component(keyword)
    puts "link: #{url} \n"
    html = URI.open(url, @headers).read

    parse_products(html)
  end

  private

  def parse_products(html)
    doc = Nokogiri::HTML(html)

    products = []

    # zamiast przez xpath to z css szukam bo chyba lekko prościej
    # znajdz wszystkie <div> z atrybutem data-component-type = s-search-result
    doc.css('div[data-component-type="s-search-result"]').each do |item|
      title_element = item.at_css('h2 span')
      whole_price = item.at_css('.a-price-whole')
      fraction_price = item.at_css('.a-price-fraction')

      next if title_element.nil? || whole_price.nil?

      title = title_element.text.strip
      fraction = fraction_price ? fraction_price.text.strip : "00"
      price = "#{whole_price.text.strip}#{fraction} PLN"

      products << Product.new(title, price)
    end

    products
  end
end