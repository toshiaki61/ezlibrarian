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

class HistoriesController < ApplicationController
  unloadable

  layout 'base'  
  before_filter :require_login
  before_filter :find_project, :authorize
  before_filter :find_treasure, :only => [:show]
  def show
    @hchs = @treasure.holder_change_histories
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
