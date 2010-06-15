#!/usr/bin/ruby

require "rubygems"
require "image_size"

DIR = "/var/www/aerial.maps.jsintl.org/data/handdrawn/"
images = []
maprefs = []
tilecache_cfg = ''
javascript = ''

def image_type(file)
  return nil if File.directory?(file)
  case IO.read(file, 10)
    when /^GIF8/: 'gif'
    when /^\x89PNG/: 'png'
    when /^\xff\xd8\xff\xe0\x00\x10JFIF/: 'jpg'
    when /^\xff\xd8\xff\xe1(.*){2}Exif/: 'jpg'
  else nil
  end
end

def create_wld(image,wld,west,south,east,north)
  open(image) do |fh|
    (x,y) = ImageSize.new(fh.read).get_size
              
    wld_string = sprintf( "%0.09f", ((east.to_f - west.to_f) / x.to_f)) + "\n"
    wld_string += "0.00000000" + "\n"
    wld_string += "0.00000000" + "\n"
    wld_string += "-" +  sprintf( "%0.09f",((north.to_f - south.to_f) / y.to_f)) + "\n"
    wld_string += west + "\n"
    wld_string += north + "\n"
    File.open(wld, 'w') {|f| f.write(wld_string) }
  end  
end

Dir.foreach( DIR ) { | file | 
  if File.directory?(DIR + file) and file.index(".") != 0

    # check for bounds
    if File.exists?(DIR + file + "/bounds")
      bounds = File.new(DIR + file + "/bounds").first
      (west,south,east,north) = bounds.split(",")
    
      Dir.foreach(DIR + file) { | image |
        if image_type(DIR + file + "/" + image)

          wld = image[0,image.rindex(".")] + ".wld"
          if ! File.exists?(DIR + file + "/" + wld)
            create_wld(DIR + file + "/" + image, DIR + file + "/" + wld, west, south, east, north)  
          end

          geotiff = image[0,image.rindex(".")] + ".tif"
          if ! File.exists?(DIR + file + "/" + geotiff)
            system("gdalwarp -s_srs 'EPSG:4326' -t_srs 'epsg:900913' " + DIR + file + "/" + image + " " + DIR + file + "/" + geotiff)
          end
          
          images << file + "/" + geotiff
	  maprefs << file + "_" + image[0,image.rindex(".")]
        end
      }
       
    end

  end
}

images.each do |image|
  id = String.new(image)
  id.sub!("/","_")
  id = id[0,id.rindex(".")]
  
  tilecache_cfg += "[" + id + "]\n"
  tilecache_cfg += "type=GDAL\n"
  tilecache_cfg += "file=" + DIR + image + "\n"
  tilecache_cfg += "tms_type=google\n"
  tilecache_cfg += "spherical_mercator=true\n"
  tilecache_cfg += "metatile=yes\n\n"
end

javascript = "images = ['"
javascript += maprefs.join("','")
javascript += "'];"

print tilecache_cfg
print javascript
