class User
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Attributes::Dynamic #For dynamic field in mongoDB documents #Prevent missing attribute error

    store_in collection: 'users'

    before_create :generate_authentication_token!

    field :email, type: String, default: ''
    field :user_name, type: String
    field :first_name, type: String
    field :last_name, type: String
    field :auth_token, type: String, default: ''

    validates_presence_of :email
    validates_presence_of :first_name

    validates_uniqueness_of :email
    validates_uniqueness_of :auth_token, allow_blank: true, allow_nil: true

    index({email: 1})

    def generate_authentication_token!
      JwtAuth.encode({user_id: id.to_s, friendly_token: SecureRandom.uuid})
    end

    def fullname
      "#{self.firstname} #{self.lastname}".strip
    end
end
