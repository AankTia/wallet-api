class User
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Attributes::Dynamic #For dynamic field in mongoDB documents #Prevent missing attribute error

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

    def generate_authentication_token!
      update(auth_token: JwtAuth.encode({uid: id.to_s, friendly_token: SecureRandom.uuid}))
    end

    def fullname
      "#{self.firstname} #{self.lastname}".strip
    end
end
