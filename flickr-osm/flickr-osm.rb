#!/usr/bin/ruby

require 'rubygems'
require 'OSM/Database'
require 'OSM/StreamParser'
require 'flickraw'

require './secret'

OSM_FILENAME = 'kibera.health.osm'
PHOTO_DIR = '/media/sda7/Kibera/photo/'
TESTING = true

def parse_osm
  db = OSM::Database.new
  parser = OSM::StreamParser.new(:filename => OSM_FILENAME, :db => db)
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
        check_and_upload(node.id, node.tags['media:camera_device_number'], camera_number.to_i, node.lat, node.lon, node.name, 'camera')
      end
    end   
  end
end

def authenticate_flickr
  return unless $auth == nil

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

def check_and_upload(id, device_number, file_number, lat, lon, name, type)
  authenticate_flickr
  
  tags = "osm:node=" + id.to_s + "," + "mapkibera:" + type + "_device=" + device_number.to_i.to_s + "," + "mapkibera:" + type + "_index=" + file_number.to_i.to_s + "," + "mapkibera,kibera,health"
  print tags
  print "\n"
  
  list = flickr.photos.search :tags => tags, :tag_mode => "all"
  if list.total.to_i > 0
    puts "Photo already uploaded"
  end
  
  photo_path = PHOTO_DIR + (device_number.to_i.to_s) + "/" +  "IMG_" + ("%04d" % file_number.to_i.to_s) + ".JPG"

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

