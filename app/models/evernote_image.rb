class EvernoteImage < Evernote::EDAM::Type::Resource
  
  attr_accessor :guid, :mime, :shard, :title, :url, :width, :height, :size

  def initialize(evernote_resource, shard,title)
    @guid = evernote_resource.guid
    @mime = evernote_resource.mime
    @size = evernote_resource.data.size
    @width = evernote_resource.width
    @height = evernote_resource.height
    
    @shard = shard
    @title = title
    self.init_image_url
  end

  def init_image_url
    @url = "#{EVERNOTE_SERVER}/shard/#{@shard}/thm/res/#{@guid}"
  end
end
