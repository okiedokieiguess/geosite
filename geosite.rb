require 'rubygems'
require 'sinatra'
require 'erb'
require 'exifr'
require 'fileutils'

helpers do
  def dms_to_float(array, ref)
    multiplier = (ref == "S" or ref == "W") ? -1 : 1
    (array[0] + array[1]/60 + array[2]/3600).to_f * multiplier
  end
end

get "/" do
  erb :index
end

get "/photos/:photo/info" do
  @image_name = params[:photo]
  @image = EXIFR::JPEG.new(File.join("photos", params[:photo]))
  @latitude = dms_to_float @image.gps_latitude, @image.gps_latitude_ref
  @longitude = dms_to_float @image.gps_longitude, @image.gps_longitude_ref
  erb :info
end

post "/photos" do
  FileUtils.mv params[:photo][:tempfile].path, File.join("photos", params[:photo][:filename])
  redirect "/photos/#{params[:photo][:filename]}/info"
end

get "/photos/:photo" do
  send_file File.join("photos", params[:photo])
end
