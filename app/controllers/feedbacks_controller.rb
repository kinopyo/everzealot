class FeedbacksController < ApplicationController

  def index
    @feedbacks = Feedback.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @feedbacks }
    end
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.json
  def show
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @feedback }
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
      redirect_to :root, notice: 'Thank you for your feedback!'
    else
      render action: "new"
    end
  end
  
end
