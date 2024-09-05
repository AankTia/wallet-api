class Wallet
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic #For dynamic field in mongoDB documents #Prevent missing attribute error

  store_in collection: 'wallets'
  
  field :balance, type: Float, default: 0.0
  
  belongs_to :user, class_name: 'User', index: true
  belongs_to :currency, class_name: 'Currency', index: true

  def balance_with_currency
    splited_balance = balance.to_s.split('.')
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
end
