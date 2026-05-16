# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

require_relative 'product'



class Crawler
  BASE_URL = "https://www.amazon.pl/s?k="
  AMAZON_HOST = "https://www.amazon.pl"

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

  def fetch_details(product)
    return product if product.url.nil?

    puts "\ndownloading details: #{product.url}"
    puts "-" * 80
    html = URI.open(product.url, @headers).read
    doc = Nokogiri.HTML(html)

    bullets = doc.css('#feature-bullets ul li span.a-list-item')
                 .map { |el| el.text.strip }
                 .reject { |t| t.empty? }
    product.description = bullets.map { |b| "- #{b}" }.join("\n") unless bullets.empty?

    product

  rescue OpenURI::HTTPError, SocketError => e
    puts "error downloading details: #{e.message}"
    product
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
      # bo w txt było widać, że zapisuje z non-breaking space
      whole = whole_price.text.strip.gsub(/\u00A0/, '')
      fraction = fraction_price ? fraction_price.text.strip : "00"
      price = "#{whole}#{fraction} PLN"

      link_element = item.at_css('a.a-link-normal[href*="/dp/"]')
      url = link_element ? AMAZON_HOST + link_element['href'].split('?').first : nil

      products << Product.new(title, price, url)
    end

    products
  end
end