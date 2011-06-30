module HomeHelper
  
  def center_padding(width, height)
    t = 300
    html = ""
    if (width < t || height < t)
      padding_left = (300-width)/2
      padding_top = (300-height)/2
      html += "padding-left:#{padding_left}px; padding-top: #{padding_top}px;"
    end
    return html
  end
  
end
