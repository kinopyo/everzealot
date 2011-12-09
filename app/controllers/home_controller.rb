class HomeController < ApplicationController
  include Download
  include FileSystem::FileZip
  before_filter :check_session, :except => [:index, :authorize, :complete]

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

        if @notebooks.size == 1
          redirect_to :controller => 'home', :action => 'show', :guid => @notebooks[0].guid
        else
          @notebooks.sort! { |a,b| a.name.downcase <=> b.name.downcase }
          session[:notebook_guids] = @notebooks.map { |e| e.guid }
        end
      rescue Exception => e
        if e.instance_of? Evernote::EDAM::Error::EDAMUserException
          case e.errorCode
          when Evernote::EDAM::Error::EDAMErrorCode::INTERNAL_ERROR
            @last_error = "Internal error in Evernote site. Please try it later."
            render :expire
          when Evernote::EDAM::Error::EDAMErrorCode::AUTH_EXPIRED
            @last_error = "Authentication expired, please authorize again."
            session[:access_token] = nil
            session[:notebook_guids] = nil
            render :expire
          when Evernote::EDAM::Error::EDAMErrorCode::PERMISSION_DENIED
            @last_error = "Sorry you have to authorize this site to use your data."
            render :error
          else
            @last_error = e.message
            render :error
          end
        else
          @last_error = "Oops, something went wrong..."
          render :error
        end
      end
    else  # if not log in
      render :welcome
    end

  end

  def show
    if params[:guid].nil?
      # FIXME
      @last_error = "parameter error"
      render :error
    else
      begin
        shard_id = session[:access_token].params['edam_shard']
        @images = []

        # if type is search all notebooks
        @guid = params[:guid]
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
      # rescue Exception => e
      #   @last_error = e
      #   render :error
      end

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
      compress_files_to_zip image_directory + "/" + zip_file_name, @selected_file
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

    # @total_pages = noteList.totalNotes / limit
    # @current_page = page
    @has_next = page * limit < noteList.totalNotes ? true : false
    @next_page = page + 1 if @has_next

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

  def check_session
    if session[:access_token].nil?
      # show expired view
      @last_error = "Oops! Your session is expired."
      render :expire
    end
  end

end
