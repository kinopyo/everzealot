class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :username
      t.string :email
      t.text :message

      t.timestamps
    end
  end
end
