class CreateAdmin < ActiveRecord::Migration[7.0]
  def change
    create_table :admin do |t|
      t.string :username
      t.string :email
      t.string :password

      t.timestamps
    end
  end
end
