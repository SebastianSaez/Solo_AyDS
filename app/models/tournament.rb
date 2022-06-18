class Tournament < ActiveRecord::Base
	has_many :tournament, foreign_key: 'tournament_id', class_name: 'Matchtournament'
end