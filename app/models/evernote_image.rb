class EvernoteImage < Object
  
  attr_accessor :guid, :mime, :shard, :title, :url

  def initialize(guid, mime, shard,title)
    @guid = guid
    @mime = mime
    @shard = shard
    @title = title
    self.init_image_url
  end

  def init_image_url
    @url = "#{EVERNOTE_SERVER}/shard/#{@shard}/thm/res/#{@guid}"
  end
end
