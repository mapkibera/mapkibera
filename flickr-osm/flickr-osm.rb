#!/usr/bin/ruby

require 'rubygems'
require 'OSM/Database'
require 'OSM/StreamParser'
require 'flickraw'

require './secret'

TESTING = true

KEY = "education" #photos, videos ready
#KEY = "watsan" #photos, videos ready
#KEY = "security" #photos done?, videos ready
#KEY = "health" #photos done, videos ready

def parse_osm
  db = OSM::Database.new
  parser = OSM::StreamParser.new(:filename => "kibera." + KEY + ".osm", :db => db)
  result = parser.parse

  db.nodes.each do |key,node|
    if node.tags['media:video_device_number'] and node.tags['media:video_number']
      video_numbers = node.tags['media:video_number'].split(",")
      video_numbers.each do |video_number|
        check_and_upload(node.id, node.tags['media:video_device_number'], video_number, node.lat, node.lon, node.name, 'video')
      end
    end
    if node.tags['media:camera_device_number'] and node.tags['media:camera_number']
      camera_numbers = node.tags['media:camera_number'].split(",")
      camera_numbers.each do |camera_number|
        check_and_upload(node.id, node.tags['media:camera_device_number'], camera_number, node.lat, node.lon, node.name, 'camera')
      end
    end   
  end
end

def authenticate_flickr
  return unless $auth == nil and ! TESTING

  if AUTH_TOKEN
    begin
      $auth = flickr.auth.checkToken :auth_token => AUTH_TOKEN
      login = flickr.test.login
      puts "You are now authenticated as #{login.username} with token #{$auth.token}"
    rescue FlickRaw::FailedResponse => e
      puts "Authentication failed : #{e.msg}"
    end 
  else
    frob = flickr.auth.getFrob
    auth_url = FlickRaw.auth_url :frob => frob, :perms => 'write'

    puts "Open this url in your process to complete the authication process : #{auth_url}"
    puts "Press Enter when you are finished."
    STDIN.getc

    begin
      $auth = flickr.auth.getToken :frob => frob
      login = flickr.test.login
      puts "You are now authenticated as #{login.username} with token #{$auth.token}"
    rescue FlickRaw::FailedResponse => e
      puts "Authentication failed : #{e.msg}"
    end
  end  
end

#NASTY
def build_photo_path(type,device_number,file_number)
  if KEY == "watsan"
    photo_dir = '/media/needle in a haystack/Media/Africa/MapKibera 2010 /Wat-San/'
    video_dir = '/media/needle in a haystack/Media/Africa/MapKibera 2010 /Wat-San/'
    if type == "camera"
     (dir,num) = file_number.split("-")
      photo_path = photo_dir + "Camera " + (device_number.to_i.to_s) + "/" + dir + "CANON/" +  "IMG_" + ("%04d" % num.to_i.to_s) + ".JPG"
    elsif type == "video"
      photo_path = video_dir + "Camera " + (device_number.to_i.to_s) +  "/" + "VID" + ("%05d" % file_number.to_i.to_s) + ".MP4"
    else
      photo_path = 'Can not determine photo path'  
    end

  elsif KEY == "education"
    photo_dir = '/media/needle in a haystack/Media/Africa/MapKibera 2010 /Education /'
    video_dir = '/media/needle in a haystack/Media/Africa/MapKibera 2010 /Education /'
    if type == "camera"
      photo_path = photo_dir + "Cam " + (device_number.to_i.to_s) + " - Photo/DCIM/all/" +  "IMG_" + ("%04d" % file_number.to_i.to_s) + ".JPG"
    elsif type == "video"
      if device_number.to_i == 3
        photo_path = video_dir + "Cam " + (device_number.to_i.to_s) +  " /Schools May 24 Mildred/" + "VID" + ("%05d" % file_number.to_i.to_s) + ".AVI"
      elsif device_number.to_i == 8
        photo_path = video_dir + "Cam " + (device_number.to_i.to_s) +  "/" + "VID" + ("%05d" % file_number.to_i.to_s) + ".MP4"
      else
        photo_path = 'Can not determine photo path'    
      end 
    else
      photo_path = 'Can not determine photo path'  
    end      

  elsif KEY == "security"
    photo_dir = '/media/needle in a haystack/Media/Africa/MapKibera 2010 /Security/'
    video_dir = '/media/needle in a haystack/Media/Africa/MapKibera 2010 /Security/'
    if type == "camera"
      photo_path = photo_dir + "Cam " + (device_number.to_i.to_s) + " (photo)/all/" +  "IMG_" + ("%04d" % file_number.to_i.to_s) + ".JPG"
    elsif type == "video"
      photo_path = video_dir + "Cam " + (device_number.to_i.to_s) +  "/" + "VID" + ("%05d" % file_number.to_i.to_s) + ".MP4"           
    else
      photo_path = 'Can not determine photo path'  
    end
    
  elsif KEY == "health"
    photo_dir = '/media/sda7/Kibera/photo/'
    video_dir = '/media/needle in a haystack/Media/Africa/MapKibera 2010 /Health/'  
    if type == "camera"
      photo_path = photo_dir + (device_number.to_i.to_s) + "/" +  "IMG_" + ("%04d" % file_number.to_i.to_s) + ".JPG"
    elsif type == "video"
      photo_path = video_dir + 'Cam ' + device_number.to_i.to_s +  "/" + "VID" + ("%05d" % file_number.to_i.to_s) + ".MP4"           
    else
      photo_path = 'Can not determine photo path'  
    end  
  end
  return photo_path
end  
  
def check_and_upload(id, device_number, file_number, lat, lon, name, type)
  return if type == "video"
  
  authenticate_flickr
  
  tags = "osm:node=" + id.to_s + "," + "mapkibera:" + type + "_device=" + device_number.to_s + "," + "mapkibera:" + type + "_index=" + file_number.to_s + "," + "mapkibera,kibera," + KEY
  print tags
  print "\n"
  
  list = flickr.photos.search :tags => tags, :tag_mode => "all"
  if list.total.to_i > 0
    puts "Photo already uploaded"
  end
        
  photo_path = build_photo_path(type,device_number,file_number)

  if File.exist?(photo_path)
    puts "Uploading File: " + photo_path
    return unless ! TESTING
    begin
      photo_id = flickr.upload_photo photo_path, :title => name, :description => "Photos from http://mapkibera.org/", :tags => tags
      flickr.photos.geo.setLocation :photo_id => photo_id, :lat => lat, :lon => lon
    rescue FlickRaw::FailedResponse => e
      puts "Upload failed : #{e.msg}"
    end    
  else
    puts "File doesn't exist: " + photo_path
  end  
end

parse_osm

