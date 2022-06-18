class AddForecasts < ActiveRecord::Migration[7.0]
  def change
    create_table :forecasts do |t|
      t.references :user
      t.references :match
      t.integer :result
      t.integer :local_goal
      t.integer :visitor_goal
      t.integer :win
      t.timestamps
    end
  end
end