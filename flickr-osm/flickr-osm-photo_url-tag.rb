#!/usr/bin/ruby

require 'rubygems'
require 'OSM/Database'
require 'OSM/StreamParser'
require 'flickraw'

require './secret'

TESTING = nil

def parse_osm
  db = OSM::Database.new
  parser = OSM::StreamParser.new(:filename => "download.osm", :db => db)
  result = parser.parse

  db.nodes.each do |key,node|
    if node.tags['photo_url']
      add_machinetags(node.id, node.tags['photo_url'], node.lat, node.lon, node.name, "node")
    end
  end
  
  db.ways.each do |key,way|
    if way.tags['photo_url']
      add_machinetags(way.id, way.tags['photo_url'], way.node_objects.first.lat, way.node_objects.first.lon, way.name, "way")
    end
  end
end

def authenticate_flickr
  return unless $auth == nil and ! TESTING

  if defined? AUTH_TOKEN
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

def numeric?(object)
  true if Float(object) rescue false
end
  
def add_machinetags(id, photo_url, lat, lon, name, type)

  authenticate_flickr
  
  tags = "osm:" + type + "=" + id.to_s
  print tags
  print "\n"
  
  photo_id = photo_url.split("/")[-1]
 
  return unless ! TESTING
  if numeric?(photo_id)
    begin
      if defined? name and name != ""
        description = (flickr.photos.getInfo :photo_id => photo_id).description
        flickr.photos.setMeta :photo_id => photo_id, :title => name, :description => description
      end
      flickr.photos.addTags :photo_id => photo_id, :tags => tags
      flickr.photos.geo.setLocation :photo_id => photo_id, :lat => lat, :lon => lon
    rescue FlickRaw::FailedResponse => e
      puts "Tagging failed : #{e.msg}"
    end    
  end
end

parse_osm

