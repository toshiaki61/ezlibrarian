class ReviewsController < ApplicationController
  unloadable

  layout 'base'  
  before_filter :require_login
  before_filter :find_treasure, :only => [:create]

  def create
    @review = Review.new(params[:review])
    @review.author_id = User.current.id
    @review.treasure = @treasure
    url = book_path(params[:id])
    if (params[:type] == 'device')
      url = device_path(params[:id])
    end
    if @review.save
      flash[:notice] = l(:notice_successful_create)
    end

    redirect_to url
  end

private
  def find_treasure
    if (params[:type] == 'book')
      @treasure = Book.find(params[:id])
    elsif (params[:type] == 'device')
      @treasure = Device.find(params[:id])
    end
    render_404 unless @treasure
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
