module Download

  IMAGE_DIRECTORY = "#{Rails.root}/tmp/images"

  # download images to server
  def download_to_server full_url, path, ext
    require 'open-uri'

    user_directory = IMAGE_DIRECTORY + "/#{session[:access_token].params['edam_userId']}"
    unless File.directory? IMAGE_DIRECTORY
      Dir::mkdir( IMAGE_DIRECTORY ) # 第二パラメータ省略時のパーミッションは0777
    end

    unless File.directory? user_directory
      Dir::mkdir( user_directory ) # 第二パラメータ省略時のパーミッションは0777
    end

    file_name = user_directory + "/" + path + '.' + ext

    # TODO is this instance variable visible from the controller which include this module?
    @selected_file << file_name
    unless File.exists?(file_name)
      File.open(file_name, 'wb') do |output|
        # Download image
        # TODO: handle if session access token is nil
        open(full_url + "?auth=#{session[:access_token].token}") do |input|
          output << input.read
        end
      end
    end
  end

end