class HomeController < ApplicationController
  def index
    @is_login = login?
    if @is_login
      shard_id = session[:access_token].params['edam_shard']
      begin
        # Construct the URL used to access the user's account
        noteStoreUrl = NOTESTORE_URL_BASE + shard_id
        noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
        noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
        noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)

        # Build an array of notebook names from the array of Notebook objects
        @notebooks = noteStore.listNotebooks(session[:access_token].token)
        @notebooks.sort! { |a,b| a.name.downcase <=> b.name.downcase }
        session[:notebook_guids] = @notebooks.map { |e| e.guid }
      rescue Exception => e
        if e.instance_of? Evernote::EDAM::Error::EDAMUserException
          if e.errorCode == Evernote::EDAM::Error::EDAMErrorCode::AUTH_EXPIRED
            @last_error = "Authentication expired, please authrize again."  #TODO here
            session[:access_token] = nil
            session[:notebook_guids] = nil
          else
            @last_error = e.message
          end
        else
          @last_error = e.message
        end
        render :error
      end
    else
      render :welcome  
    end
    
  end

  def show
    if params[:guid].nil?
      @last_error = "parameter error"
      erb :error
    else
      begin
        shard_id = session[:access_token].params['edam_shard']   
        @images = []

        # if type is search all notebooks

        if (params[:guid] == "all")
          session[:notebook_guids].each do |notebook_guid|
            image = fetch_image_from_notebook(shard_id, notebook_guid, params[:page])
            @images = @images + image unless image.blank?
          end
        else  # if search selected notebook
          @images = fetch_image_from_notebook(shard_id, params[:guid], params[:page])
        end
        render :show
      rescue Evernote::EDAM::Error::EDAMUserException => e
        @last_error = e.errorCode
        render :error
      rescue Exception => e
        @last_error = e
        render :error
      end

    end
  end

  def authorize
    callback_url = request.url.chomp("authorize").concat("complete")

    begin
      consumer = OAuth::Consumer.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET,{
          :site => EVERNOTE_SERVER,
          :request_token_path => "/oauth",
          :access_token_path => "/oauth",
          :authorize_path => "/OAuth.action?format=microclip"})
      session[:request_token] = consumer.get_request_token(:oauth_callback => callback_url)
      redirect_to session[:request_token].authorize_url
    rescue Exception => e
      @last_error = "Error obtaining temporary credentials. Please try later."
      p "Log::Error,  #{e.inspect}"
      render :error
    end
  end
  
  def complete
    if (params['oauth_verifier'].nil?)
      Rails.logger.debug { " owner did not authorize the temporary credentials" }
      @last_error = "Oops! You need to authorize this website first."
      render :error
    else
      oauth_verifier = params['oauth_verifier']
      session[:access_token] = session[:request_token].get_access_token(:oauth_verifier => oauth_verifier)
      redirect_to '/'

    end
  end
  
  #actions
  def action
    if params[:images].nil?
      @last_error = "please select images"
      render :error 
      return
    end
    
    @selected_file = Array.new
    @image_urls = Array.new
    params[:images].each do |image|
      # image/png, image/jpeg  extract the part after slash as file ext
      param = image.match(/guid=(.*)&mime=image\/(.*)/)
      guid = param[1]
      ext = param[2]
      
      shard = session[:access_token].params['edam_shard']
      # set www or sandbox in env config file
      @image_urls << "https://www.evernote.com/shard/#{shard}/res/#{guid}"
      download_to_server "http://www.evernote.com/shard/#{shard}/res/#{guid}", "#{guid}", "#{ext}"
    end
    
    case params[:operation]
    when 'Send Mail'
      session[:files] = @selected_file  # TODO change to a good way to keep this info
      session[:image_urls] = @image_urls
      # render :action => "new_mail"
      redirect_to :controller => "emails", :action => "new"
    when 'Download'
      image_directory = "#{Rails.root}/tmp/images/#{session[:access_token].params['edam_userId']}"
      zip_file_name = "evernote_images_#{session[:access_token].params['edam_userId']}.zip"
      zip_image image_directory + "/" + zip_file_name
      # make this zip file download
      send_file image_directory + "/" + zip_file_name, :type => "application/zip"

      @selected_file = nil
    else
      render :text => 'no action'
    end

  end
  
  def send_mail
    UserMailer.send_image_mail(params[:to], params[:from], params[:subject], 
      params[:message], session[:files], params[:attach]).deliver
    render :text => "mail sent"
  end
  
  def reset
    session[:access_token] = nil
    redirect_to :root
  end
  
  private
  
  def fetch_image_from_notebook(shard, notebook_guid, page = 1,limit = 30 )
    # Construct the URL used to access the user's account
    noteStoreUrl = NOTESTORE_URL_BASE + shard
    noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
    noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
    noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)

    # Find notes from specified notebook
    noteFilter = Evernote::EDAM::NoteStore::NoteFilter.new()
    noteFilter.notebookGuid = notebook_guid

    page = page.to_i
    page = 1 if page < 1
    offset = (page-1) * limit
    # NoteList findNotes(string authenticationToken, NoteFilter filter, i32 offset,i32 maxNotes)
    # even set the count to max(Evernote::EDAM::Limits::EDAM_USER_NOTES_MAX), it still just fetch 50 notes.
    noteList = noteStore.findNotes(session[:access_token].token, noteFilter, offset, limit)
p "noteList.totalNotes #{noteList.totalNotes}"
    @has_next = page * limit < noteList.totalNotes ? true : false
    
    ret = []
    noteList.notes.each do |note|
      next if note.resources.nil?
      note.resources.each do |resource|
        if is_image(resource.mime)
          ret << EvernoteImage.new(resource, session[:access_token].params['edam_shard'], note.title)
        end
      end
    end
    ret unless ret.blank?
  end
  
  # download images to server
  def download_to_server full_url, path, ext
    require 'open-uri'
    image_directory = "#{Rails.root}/tmp/images"
    user_directory = image_directory + "/#{session[:access_token].params['edam_userId']}"
    unless File.directory? image_directory 
      Dir::mkdir( image_directory ) # 第二パラメータ省略時のパーミッションは0777
    end
    
    unless File.directory? user_directory 
      Dir::mkdir( user_directory ) # 第二パラメータ省略時のパーミッションは0777
    end
    
    file_name = user_directory + "/" + path + '.' + ext

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
  
  def zip_image filename
    # https://bitbucket.org/winebarrel/zip-ruby/wiki/Home
    
    File.delete(filename) if File.exists?(filename)

    Zip::Archive.open(filename, Zip::CREATE) do |ar|
        @selected_file.each do |file|
          ar.add_file(file)
          # File.delete(file) # delete file after added to zip
        end
    end
  end
  
end
