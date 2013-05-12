class StatementsController < ApplicationController
  unloadable

  layout 'base'
  before_filter :require_login

  def index
    list = Book.find(:all).collect{|b|b.holder_id}
    device_list = Device.find(:all).collect{|d|d.holder_id}
    unless device_list.empty?
      list += device_list
    end
    @user_list = list.uniq
  end

  def create
    @list = params[:list]
    unless @list.nil?
      @user = User.find(:all, :conditions => ['id in (?)', @list])
      @list.each{|id| LibMailer.deliver_send_statement_each(id)}
      
      flash[:notice] = l(:text_send_successful)
    end
    redirect_to :action => 'index'
  end
end
