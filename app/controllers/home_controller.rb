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
        session[:notebooks] = @notebooks
      rescue Exception => e
        @last_error = e.message
        render :error
      end
      
    end
  end

  def show
    if params[:guid].nil?
      @last_error = "parameter error"
      erb :error
    else
      begin
        shard_id = session[:access_token].params['edam_shard']   
        # to hold the last note guid
        last_note_guid = ""

        # Construct the URL used to access the user's account
        noteStoreUrl = NOTESTORE_URL_BASE + shard_id
        noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
        noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
        noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)

        # Find notes from specified notebook
        noteFilter = Evernote::EDAM::NoteStore::NoteFilter.new()

        # if type is search all notebooks
        if (params[:guid] == "all")
          @notes = Array.new
          session[:notebooks].each do |notebook|
            noteFilter.notebookGuid = notebook.guid
            noteList = noteStore.findNotes(session[:access_token].token, noteFilter, 0, Evernote::EDAM::Limits::EDAM_USER_NOTES_MAX)
            noteList.notes.each do |note|
              unless note.resources.nil?
                note.resources.each do |resource|
                  if is_image(resource.mime)
                    # if one note has more than one image         
                    # use the local variable to check
                    @notes << note if last_note_guid != note.guid
                    last_note_guid = note.guid
                  end
                end
              end
            end
          end
        else  # if search selected notebook
          noteFilter.notebookGuid = params[:guid]
          noteList = noteStore.findNotes(session[:access_token].token, noteFilter, 0, Evernote::EDAM::Limits::EDAM_USER_NOTES_MAX)
          @notes = Array.new
          noteList.notes.each do |note|
            unless note.resources.nil?            
              note.resources.each do |resource|
                if is_image(resource.mime)  
                  # if one note has more than one image         
                  # use the local variable to check
                  @notes << note if last_note_guid != note.guid 
                  last_note_guid = note.guid
                end
              end
            end
          end
        end
        
        render :show
      rescue Evernote::EDAM::Error::EDAMUserException => e
        @last_error = e.errorCode
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
      @last_error = "Error obtaining temporary credentials: #{e.message}"
      render :error
    end
  end
  
  def complete
    if (params['oauth_verifier'].nil?)
      @last_error = "Content owner did not authorize the temporary credentials"
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
      
      @image_urls << "https://sandbox.evernote.com/shard/#{params[:shard]}/res/#{guid}"
      download_to_server "http://sandbox.evernote.com/shard/#{params[:shard]}/res/#{guid}", "#{guid}", "#{ext}"
    end
    
    case params[:operation]
    when 'Send Mail'
      session[:files] = @selected_file  # TODO change to a good way to keep this info
      render :action => "new_mail"
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
