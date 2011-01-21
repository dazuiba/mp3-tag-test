require "mp3info"
require "string_ext"
class Mp3TagParser
  attr_accessor :file, :encoding, :result_info
  def initialize(file, encoding)
		@file = file
		@encoding = encoding
	end

	def parse
		info = {}
		options = {}
		if !encoding.blank?
		  options = {:encoding => encoding}
	  end
		Mp3Info.open(@file,options) do |mp3|
			info[:title] = decode(mp3.tag.title)
			info[:artist] = decode(mp3.tag.artist)
			info[:album] = decode(mp3.tag.album)
			info[:tracknum] = decode(mp3.tag.tracknum)
		end
		@result_info = info
	end

private
	def decode(str)
	  return str if !str.is_a?(String)
	  if encoding =~/utf\-8/i
	    str
    else
	    str.to_utf8
    end
	end

end

class Mp3infoController < ApplicationController
	def index
		return if request.get?
		if !File.directory?(params[:dir])
			@error = "请输入正确的目录！"
			return
		end
		
		params[:dir].sub!(/\\|\/$/,"")
		file_list = Dir.glob(params[:dir]+"/#{params[:rec] ? '**/*' : '*'}.mp3").select{|e|File.file?(e)}
		
		if file_list.empty?
			@error = "该目录没有Mp3文件"
			return
		end
		@encoding = params[:encoding]
		@infos = file_list.map{|e|[e, Mp3TagParser.new(e,@encoding).parse]}
		puts @infos.inspect
	end
end