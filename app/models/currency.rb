class Currency
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic #For dynamic field in mongoDB documents #Prevent missing attribute error

  store_in collection: 'currencies'
  
  has_many :wallets, class_name: 'Wallet'
  
  field :iso_code, type: String
  field :name, type: String
  field :symbol, type: String
  field :symbol_first, type: Boolean, default: true
  field :thousands_separator, type: String, default: '.'
  field :decimal_mark, type: String, default: ','

  validates_presence_of :iso_code, :name, :symbol
  validates_uniqueness_of :iso_code
end
