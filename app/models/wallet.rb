class Wallet
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic #For dynamic field in mongoDB documents #Prevent missing attribute error

  store_in collection: 'wallets'
  
  belongs_to :user, class_name: 'User', index: true
  belongs_to :currency, class_name: 'Currency', index: true
  has_many :transactions, class_name: 'Transaction'
  
  field :phone_number, type: String 
  field :balance, type: Float, default: 0.0

  validates_presence_of :phone_number
  validates_uniqueness_of :user_id

  def balance_with_currency
    splited_balance = balance.round(currency.decimal_round).to_s.split('.')
    non_decimal_value = splited_balance.first
    decimal_value = splited_balance.last

    non_decimal_value = non_decimal_value.reverse                            #=> "12345678" => "87654321"
                                         .scan(/\d{1,3}/)                    #=> ["876","543","21"]
                                         .join(currency.thousands_separator) #=> "876,543,21"
                                         .reverse                            #=> "12,345,678"

    formated_balance = "#{non_decimal_value}#{currency.decimal_mark}#{decimal_value}"
    if currency.symbol_first
      "#{currency.symbol} #{formated_balance}"
    else
      "#{formated_balance} #{currency.symbol}"
    end
  end

  def credit(value)
    inc(balance: value)
  end

  def debit(value)
    inc(balance: -value)
  end
  
  # Class methods
  class << self
    def init_for_user(user, currency_code='IDR')
      currency = Currency.find_by(iso_code: currency_code)
      create!(user: user, phone_number: user.phone_number, currency: currency)
    end

    def find_by_phone_number(phone_number)
      find_by(phone_number: phone_number)
    end
  end
end
