# frozen_string_literal: true

require 'fileutils'



class StorageTXT
  DIR = "storage"

  # dzięki self to metoda statyczna
  def self.save_products(products, keyword)
    FileUtils.mkdir_p(DIR)

    filename = "products_#{set_filename(keyword)}.txt"
    path = File.join(DIR, filename)

    File.open(path, "a") do |file|
      products.each do |product|
        file.puts "PRODUCT: #{product.title}"
        file.puts "PRICE: #{product.price}"

        if product.url
          file.puts "URL: #{product.url}"
        end

        file.puts "-" * 50
      end
    end
  end

  def self.set_filename(name)
    name
      .downcase
      .strip
      .gsub(/\s+/, "_")
      .gsub(/[^a-z0-9_]/, "")
  end
end
