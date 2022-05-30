require 'bcrypt'
class User < ActiveRecord::Base

    has_many :forecasts
    has_secure_password
    validates :username, presence: true, uniqueness: true
end


class Player < User
    has_many :championbets
    has_many :bets
    has_many :scores
end

class Admin < User
end