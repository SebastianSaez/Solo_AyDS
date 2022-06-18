class Matchtournament < ActiveRecord::Base
    belongs_to :match, class_name: 'Match'
    belongs_to :tournament, class_name: 'Tournament'
end