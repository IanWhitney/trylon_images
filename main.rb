#require 'set'
require 'pp'
require 'RMagick'
include Magick
require 'fileutils'

def delete_with_extension(dir,extension)
  files_to_delete = Dir["#{dir}**/*#{extension.downcase}"]
  files_to_delete += Dir["#{dir}**/*#{extension.upcase}"]
  files_to_delete.each {|f| File.delete(f)}
end

class String
  def extension
    self.match(/\.(\w+)$/)[1]
  end
end

module Magick
  class Image
    def aspect_wider_than?(x)
      self.columns.to_f/self.rows.to_f > x
    end
  end
end

def copy_with_path(src, dst)
  FileUtils.mkdir_p(File.dirname(dst))
  FileUtils.cp(src, dst)
end

base_path = "/Volumes/Other/raw"
all_directories = Dir["#{base_path}/**/*/"]

all_directories.each do |dir|
  %w(pdf eps mp4 doc mov asf avi psd lnk db).each do |e|
    delete_with_extension(dir, e)
  end

  contents = Dir["#{dir}**/*"].reject {|fn| File.directory?(fn) }

  contents.each do |f|
    i = Magick::Image::read(f).first
    copy_with_path(f,f.sub("Other/raw","Other/wide")) if i.aspect_wider_than?(1.6)
    i = nil
    GC.start
  end
  GC.start
end
