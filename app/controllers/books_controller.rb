class BooksController < ApplicationController
  unloadable

  helper :sort
  include SortHelper

  layout 'base'  
  before_filter :require_login, :find_user
  before_filter :find_book, :only => [:show, :edit, :update, :destroy, :return, :borrow]
  
  def index
    sort_init "title", "asc"
    sort_update %w(id title author publisher published_on holder_id holder_change_histories_count reviews_count)

    conditions = params[:title].nil? ? {} : {:conditions => ['title LIKE ?', '%#{params[:title]}%']}
    @count = Book.count(conditions)
    @pages = Paginator.new @count, per_page_option, params['page']
    @treasures = Book.find(:all,
      conditions.merge(
        :order => sort_clause,
        :limit  =>  @pages.per_page,
        :offset =>  @pages.offset
      )
    )
    render :layout => !request.xhr?
  end

  def return
    return_to = Setting.plugin_redmine_ezlibrarian['return_to']
    @book.holder_id = return_to
    @book.updater_id = return_to
    if @book.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    end

  end

  def borrow
    @book.holder_id = User.current.id
    @book.updater_id = User.current.id
    if @book.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    end
  end

  def new
  end

  def create
    @book = Book.new(params[:book])
    if request.post? && @book.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'show', :id => @book
    end
  end

  def edit
  end

  def update
    @book.attributes = params[:book]
    if request.xhr?
      #render :json
    end
    if @book.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'show', :id => @book
    end
  rescue ActiveRecord::StaleObjectError
    # Optimistic locking exception
    flash.now[:error] = l(:notice_locking_conflict)
    redirect_to :action => 'edit', :id => @book
  end

  def show
    @reviews = @book.reviews
  end

  def destroy
    @book.destroy
    redirect_to :action => 'index'
  end

private
  def find_user
    @users = User.find(:all, :conditions => ['status = ?', User::STATUS_ACTIVE])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_book
    @book = Book.find(params[:id])
    render_404 unless @book
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
