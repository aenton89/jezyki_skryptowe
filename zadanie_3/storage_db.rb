# frozen_string_literal: true

require 'sequel'
require 'fileutils'



class StorageDB
  DIR = "storage"
  DB_PATH = File.join(DIR, "products.db")

  FileUtils.mkdir_p(DIR)

  DB = Sequel.sqlite(DB_PATH)

  def self.save_products(products, keyword)
    table_name = table_name(keyword)

    DB.create_table? table_name do
      primary_key :id
      String :title
      String :price
      String :url, text: true
    end

    dataset = DB[table_name]

    products.each do |product|
      dataset.insert(
        title: product.title,
        price: product.price,
        url: product.url
      )
    end
  end

  def self.table_name(keyword)
    "products_#{sanitize(keyword)}".to_sym
  end

  def self.sanitize(name)
    name
      .downcase
      .strip
      .gsub(/\s+/, "_")
      .gsub(/[^a-z0-9_]/, "")
  end
end