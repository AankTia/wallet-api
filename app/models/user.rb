class User
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Attributes::Dynamic #For dynamic field in mongoDB documents #Prevent missing attribute error

    before_save :set_auth_token, if: :new_record?
    after_save :init_wallet, if: :wallet_not_exists?
    
    store_in collection: 'users'

    has_one :wallet, class_name: 'Wallet'

    field :email, type: String, default: ''
    field :user_name, type: String
    field :phone_number, type: String
    field :first_name, type: String
    field :last_name, type: String
    field :auth_token, type: String, default: ''

    validates_presence_of :email, :first_name, :phone_number
    validates_uniqueness_of :email, :phone_number
    validates_uniqueness_of :auth_token, allow_blank: true, allow_nil: true

    index({email: 1})

    def set_auth_token
      auth_token = generate_auth_token
    end

    def init_wallet
      Wallet.init_for_user(self)
    end

    def wallet_not_exists?
      !wallet.present?
    end

    def generate_auth_token
      JwtAuth.encode({uid: id.to_s, friendly_token: SecureRandom.uuid})
    end

    def fullname
      "#{self.first_name} #{self.last_name}".strip
    end
end
