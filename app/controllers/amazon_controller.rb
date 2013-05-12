require 'asin'

class AmazonController < ApplicationController
  unloadable

  include ASIN::Client
  ASIN::Configuration.configure do |config|
    config.secret = Setting.plugin_redmine_ezlibrarian['secret']
    config.key = Setting.plugin_redmine_ezlibrarian['key']
    config.associate_tag = Setting.plugin_redmine_ezlibrarian['associate_tag']
    config.host = Setting.plugin_redmine_ezlibrarian['host']
    config.version = Setting.plugin_redmine_ezlibrarian['version']
  end

  before_filter :require_login

  def index
    items = search_keywords params[:query]
    render :json => {
      'error' => '',
      'query' => params[:query],
      'suggestions' => items
    }
  rescue REXML::ParseException => e
    render :json => {
      'error' => e,
      'query' => params[:query],
      'suggestions' => []
    }
    render_500
  end
end
