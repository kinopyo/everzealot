class FeedbacksController < ApplicationController

  def index
    @feedbacks = Feedback.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.json
  def show
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @feedback = Feedback.new
  end


  def create
    @feedback = Feedback.new(params[:feedback])
                                                                                    
    if @feedback.save                        
      # send to admin                                                   
      # TODO delay job
      UserMailer.send_feedback(params[:feedback]).deliver
      flash[:notice] = 'Thank you for your feedback!'
      redirect_to :root 
    else
      render :new
    end
  end
  
end
