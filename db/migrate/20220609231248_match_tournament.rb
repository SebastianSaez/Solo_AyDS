class MatchTournament < ActiveRecord::Migration[7.0]
  def change
    create_table :matchtournaments do |t|
      t.references :match
      t.references :tournament
      t.string :date
      t.string :hour
      t.timestamps
    end
  end
end
