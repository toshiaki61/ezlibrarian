# ezLibrarian plugin for redMine
# Copyright (C) 2008-2009  Zou Chaoqun
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'asin'

class TreasuresController < ApplicationController
  unloadable

  helper :sort
  include SortHelper

  include ASIN::Client
  ASIN::Configuration.configure do |config|
    config.secret = Setting.plugin_redmine_ezlibrarian['secret']
    config.key = Setting.plugin_redmine_ezlibrarian['key']
    config.associate_tag = Setting.plugin_redmine_ezlibrarian['associate_tag']
    config.host = Setting.plugin_redmine_ezlibrarian['host']
    config.version = Setting.plugin_redmine_ezlibrarian['version']
  end

  layout 'base'  
  before_filter :require_login
  before_filter :find_project, :authorize
  before_filter :find_book, :only => [:show_book, :edit_book, :destroy_book, :return_book, :borrow_book]
  before_filter :find_device, :only => [:show_device, :edit_device, :destroy_device]
  before_filter :find_treasure, :only => [:add_review, :show_holder_change_histories]
  
  def index
    sort_init "title", "asc"
    sort_update %w(id title author publisher published_on holder_id holder_change_histories_count reviews_count)

    @type = 'book'
    @type_is_book = true
    @partial = 'treasures/list_book'
    @count = Book.count
    @pages = Paginator.new self, @count, per_page_option, params['page']
    @treasures = Book.find(:all, :order => sort_clause,
      :limit  =>  @pages.items_per_page,
      :offset =>  @pages.current.offset)

    render :template => 'treasures/index.html.erb', :layout => !request.xhr?
  end

  def amazon
    items = search_keywords params[:query]
    render :json => {'query'=>params[:query],'suggestions'=>items}
  end

  def return_book
    return_to = Setting.plugin_redmine_ezlibrarian['return_to']
    @book.holder_id = return_to
    @book.updater_id = return_to
    @book.save
    redirect_to :action => 'index'
  end

  def borrow_book
    @book.holder_id = User.current.id
    @book.updater_id = User.current.id
    @book.save
    redirect_to :action => 'index'
  end

  def index_of_devices
    sort_init "name", "asc"
    sort_update %w(id name vendor model value manufactured_on holder_id holder_change_histories_count reviews_count)

    @type = 'device'
    @type_is_book = false
    @partial = 'treasures/list_device'
    @count = Device.count
    @pages = Paginator.new self, @count, per_page_option, params['page']
    @treasures = Device.find(:all, :order => sort_clause,
      :limit  =>  @pages.items_per_page,
      :offset =>  @pages.current.offset)

    render :template => 'treasures/index.html.erb', :layout => !request.xhr?
  end

  def new_book
    @book = Book.new(params[:book])
    if request.post? && @book.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'show_book', :id => @book
    end    
  end

  def new_device
    @device = Device.new(params[:device])
    if request.post? && @device.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'show_device', :id => @device
    end
  end

  def edit_book
    if request.post?
      @book.attributes = params[:book]
      if @book.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'show_book', :id => @book
      end      
    end
  rescue ActiveRecord::StaleObjectError
    # Optimistic locking exception
    flash.now[:error] = l(:notice_locking_conflict)    
  end

  def edit_device
    if request.post?
      @device.attributes = params[:device]
      if @device.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'show_device', :id => @device
      end
    end
  rescue ActiveRecord::StaleObjectError
    # Optimistic locking exception
    flash.now[:error] = l(:notice_locking_conflict)
  end

  def show_book
    @reviews = @book.reviews
  end

  def show_device
    @reviews = @device.reviews
  end

  def destroy_book
    @book.destroy
    redirect_to :action => 'index'
  end

  def destroy_device
    @device.destroy
    redirect_to :action => 'index_of_devices'
  end

  def add_review
    @review = Review.new(params[:review])
    @review.author_id = User.current.id
    @review.treasure = @treasure
    if request.post?
      @review.save
      redirect_to :action => @show_action, :id => params[:id]
    end
  end

  def show_holder_change_histories
    @hchs = @treasure.holder_change_histories
  end
  
  def show_statement
    list=Book.find(:all).collect{|b|b.holder_id} + Device.find(:all).collect{|d|d.holder_id}
    @user_list = list.uniq
	  render :template => 'treasures/show_statement.html.erb', :layout => !request.xhr?
  end

  def send_statement
    @list=params[:list]
	  @user=User.find(:all,:conditions=>["id in (?)",@list])
    
    @list.each{|id| LibMailer.deliver_send_statement_each(id)}
    
    flash[:notice]=l(:text_send_successful)
    redirect_to :action => 'show_statement'
  end

private
  def find_project
    @users=User.find(:all,:conditions=>["status = ?", User::STATUS_ACTIVE])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def authorize
    User.current.logged?
  end
  
  def find_book
    @book = Book.find(params[:id])
    render_404 unless @book
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_device
    @device = Device.find(params[:id])
    render_404 unless @device
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_treasure
    if (params[:type] == 'book')
      find_book
      @treasure = @book
      @show_action = 'show_book'
      @treasure_name = @book.title
    elsif (params[:type] == 'device')
      find_device
      @treasure = @device
      @show_action = 'show_device'
      @treasure_name = @device.name
    else
      render_404
    end
  end
end
