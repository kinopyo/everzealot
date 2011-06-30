class EvernoteImage < Evernote::EDAM::Type::Resource
  
  attr_accessor :guid, :mime, :shard, :title, :url, :width, :height, :size

  def initialize(evernote_resource, shard,title)
    @guid = evernote_resource.guid
    @mime = evernote_resource.mime
    @size = evernote_resource.data.size
    # TODO some image resource down not contain width and height
    @width = set_if_not_nil(evernote_resource.width, 300)
    @height = set_if_not_nil(evernote_resource.height, 300)
    
    @shard = shard
    @title = title
    self.init_image_url
  end

  def init_image_url
    @url = "#{EVERNOTE_SERVER}/shard/#{@shard}/thm/res/#{@guid}"
  end
  
  def set_if_not_nil(value, default)
    if value.nil?
      default
    else
      value
    end
  end
end
