class DevicesController < ApplicationController
  unloadable

  helper :sort
  include SortHelper

  layout 'base'  
  before_filter :require_login, :find_user
  before_filter :find_device, :only => [:show, :edit, :update, :destroy]
  
  def index
    sort_init "name", "asc"
    sort_update %w(id name vendor model value manufactured_on holder_id holder_change_histories_count reviews_count)

    @count = Device.count
    @pages = Paginator.new @count, per_page_option, params['page']
    @treasures = Device.find(:all,
      :order => sort_clause,
      :limit  =>  @pages.per_page,
      :offset =>  @pages.offset)
  end

  def new
  end

  def create
    @device = Device.new(params[:device])
    if @device.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'show', :id => @device
    end
  end

  def edit
  end

  def update
    @device.attributes = params[:device]
    if @device.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'show', :id => @device
    end
  rescue ActiveRecord::StaleObjectError
    # Optimistic locking exception
    flash.now[:error] = l(:notice_locking_conflict)
  end

  def show
    @reviews = @device.reviews
  end

  def destroy
    @device.destroy
    redirect_to :action => 'index'
  end

private
  def find_user
    @users = User.find(:all, :conditions => ['status = ?', User::STATUS_ACTIVE])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_device
    @device = Device.find(params[:id])
    render_404 unless @device
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
