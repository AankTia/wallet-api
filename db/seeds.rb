# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seed Currencies Start"
currencies_data = [
  { iso_code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', symbol_first: true, decimal_mark: ',', thousands_separator: '.' },
  { iso_code: 'USD', name: 'United States Dollar', symbol: '$', symbol_first: true, decimal_mark: '.', thousands_separator: ',' },
  { iso_code: 'EUR', name: 'Euro', symbol: "€", symbol_first: true, decimal_mark: ',', thousands_separator: '.' }
]

currencies_data.each do |data|
  currency = Currency.find_by(iso_code: data[:iso_code])
  if currency.present?
    is_new_record = false
    currency.attributes = data
  else
    is_new_record = true
    currency = Currency.new(data)
  end

  if currency.save
    puts " -> Successfully #{is_new_record ? 'Create' : 'Update'} Currency with iso_code: #{data[:iso_code]}"
  else
    puts " -> Failed #{is_new_record ? 'Create' : 'Update'} Currency with iso_code: #{data[:iso_code]}, #{currency.errors.full_messages.to_sentence}"
  end
end
puts "Seed Currencies Finished"