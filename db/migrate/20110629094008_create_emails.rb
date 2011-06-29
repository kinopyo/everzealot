class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :from_email
      t.string :to_email
      t.text :message
      t.string :subject
      t.boolean :attach
      t.string :cc

      t.timestamps
    end
  end
end
