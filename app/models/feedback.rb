class Feedback < ActiveRecord::Base
  validates :message, :presence => true, :length => {:maximum => 500}

end
