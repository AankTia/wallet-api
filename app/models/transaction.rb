class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic #For dynamic field in mongoDB documents #Prevent missing attribute error

  ON_PROGRESS = 'on_progress'.freeze
  SUCCESS = 'success'.freeze
  FAILED = 'failed'.freeze
  ERROR = 'error'.freeze

  store_in collection: 'transactions'
  
  belongs_to :wallet, class_name: 'Wallet', index: true

  field :amount, type: Float, default: 0.0
  field :status, type: String, default: ON_PROGRESS
  field :notes, type: String, default: ''

  validates_presence_of :amount
  validates_numericality_of :amount, if: :amount_present?

  validates :status, inclusion: { in: [ON_PROGRESS, SUCCESS, FAILED], message: "%{value} is not a valid status" }

  def amount_present?
    amount.present?
  end

  def is_success?
    status == SUCCESS
  end

  def is_failed?
    status == FAILED
  end

  def is_error?
    status == ERROR
  end
end
