require 'bcrypt'
class User < ActiveRecord::Base

    has_many :forecasts
    has_secure_password
    validates :username,:email, presence: true, uniqueness: true
    before_create do
        self.point = 0
        self.streak = 0
    end
end


class Player < User
    
end
