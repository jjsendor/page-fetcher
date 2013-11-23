require 'rest-client'
require 'json'

class PagesController < ApplicationController
  def index
    @page = FacebookPage.new
    @pages = FacebookPage.all
  end

  def create
    id = params[:page][:id]
    puts "Facebook page id: #{id}"

    begin
      @page = FacebookPage.find(id)
      flash[:notice] = "Page already added."
    rescue ActiveRecord::RecordNotFound
      begin
	response = RestClient.get "https://graph.facebook.com/#{id}?fields=name,picture"

	data = JSON.parse(response)
	@page = FacebookPage.new
	@page.id = id
	@page.name = data['name']
	@page.picture = data['picture']['data']['url']

	if @page.save
	  flash[:notice] = "Page added."
	else
	  flash[:notice] = "Page cannot be added."
	end
      rescue RestClient::BadRequest
	flash[:notice] =  "Page does not exist."
      end
    end

    redirect_to action: 'index'
  end
  
  def show
    @page = FacebookPage.find(params[:id])
    @feed = []

    begin
      response = RestClient.get("https://graph.facebook.com/#{@page.id}/feed?fields=from,message,created_time&limit=10",
	:access_token => "CAACEdEose0cBAOPulqZB33r74WpSW9n0UZCQ0WlO9XhuhccmVwFYSgAbLLBVbl86uTYk16kOI7vStCrs9QRVITJe4lQVGLuE0Ylpp1m0Sfxd56prmK2YQB6ORhPoDOIENkeIIjZCbhpZAEHBbZCVLz0lx9l4n1JN7OZAglkGlKhHXlMSOTbmDmsnn0JuBjZA8QeZBDT2vFkQmAZDZD")
      @feed = JSON.parse(response)['data']
    rescue RestClient::BadRequest
      flash[:notice] = "Error fetching the page feed."
    end
  end
end
