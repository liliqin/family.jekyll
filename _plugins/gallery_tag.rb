# Connects Jekyll with photo gallery
# currently support Lychee (http://lychee.electerious.com/)
#
# # Features
#
# * Generate album overview and link to image
# * Caching of JSON data
#
# # Usage
#
#   {% album <album_id> %}
#   {% album_no_cache <album_id> %}
#
#   {% photo <album_id> <photo_id> %}
#   {% photo_no_cache <album_id> <photo_id> %}
#
# # Example
#
#   {% album 1 %}
#   {% album_no_cache 1 %}
#
#   {% photo 1 14280199474188 %}
#   {% photo_no_cache 1 14280199474188 %}
#
# # Default configuration (override in _config.yml)
#
#   gallery:
#     url: http://gallery.limaoxu.com
#     path: gallery/
#     title_tag: h1
#     link_to: gallery
#     cache_folder: _gallery_cache
#
# Change at least "url" to your own installation
# title_tag: let's you chose which HTML tag to use around the album title
# link_to: choose "gallery" or "origin".
#   gallery: links the image to the gallery image view
#   origin: links the image to it's original image
#
# # Author and license
#
# Limlabs <support@limlabs.com> - http://www.limlabs.com
# License: MIT
#
# Based on Lychee Tag
# Tobias Brunner <tobias@tobru.ch> - https://tobrunet.ch
# License: MIT

require 'json'
require 'net/http'
require 'net/https'
require 'uri'

module Jekyll
  class AlbumTag < Liquid::Tag
    def initialize(tag_name, config, token)
      super

      # params coming from the liquid tag
      @params = config.strip
      @album_id = @params
      
      # get config from _config.yml
      @config = Jekyll.configuration({})['gallery'] || {}
      # set default values
      @config['url']             ||= 'http://gallery.limaoxu.com'
      @config['path']            ||= '/gallery/'
      @config['title_tag']       ||= 'h1'
      @config['link_to']         ||= 'gallery'
      @config['cache_folder']    ||= '_gallery_cache'

      # initialize caching
      @cache_disabled = false
      @cache_folder = File.expand_path "../#{@config['cache_folder']}", File.dirname(__FILE__)
      FileUtils.mkdir_p @cache_folder

    end

    def render(context)
      # initialize session with gallery
      api_url = @config['url'] + "/php/api.php"
      uri = URI.parse(api_url)
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = false
      @request = Net::HTTP::Post.new(uri.request_uri)
      @request['Cookie'] = init_gallery_session

      album = cached_response(@album_id, 'album') || get_album(@album_id)
      puts "[Gallery Tag] Processing album id #{@album_id}: '#{album['title']}'"
      # html = "<#{@config['title_tag']}>#{album['title']}</#{@config['title_tag']}>\n"
      html = ""
      album_content = album['content']
      album_content.each do |photo_id, photo_data|
        big_href = case @config['link_to']
          when "origin"
            photo_data = cached_response(photo_id, 'photo') || get_photo(@album_id, photo_id)
            @config['path'] + photo_data['url']
          when "gallery" then @config['path'] + "#" + @album_id + "/" + photo_id
          else "#"
        end
        html << "<a href=\"#{big_href}\" title=\"#{photo_data['title']}\" target=\"_blank\"><img src=\"#{@config['path']}#{photo_data['thumbUrl']}\"/></a>"
      end
      return html
    end

    # Caching
    def cache(id, type, data)
      puts "[Gallery Tag] Caching #{type} id #{id}"
      cache_file = cache_file_for(id, type)
      File.open(cache_file, "w") do |f|
        f.write(data)
      end
    end

    def cache_file_for(id, type)
      filename = "#{type}_#{id}"
      File.join(@cache_folder, filename)
    end

    def cached_response(id, type)
      return nil if @cache_disabled
      cache_file = cache_file_for(id, type)
      JSON.parse(File.read(cache_file)) if File.exist?(cache_file)
    end


    # Gallery API mapping
    def init_gallery_session
      # construct request
      @request.set_form_data({'function' => 'init'})
      # send request now and save cookies
      response = @http.request(@request)
      return response.response['set-cookie']
    end
    def get_albums
      @request.set_form_data({'function' => 'getAlbums'})
      return JSON.parse(@http.request(@request).body)
    end
    def get_album(id)
      @request.set_form_data({'function' => 'getAlbum', 'albumID' => id, 'password' => ''})
      response = @http.request(@request).body
      cache(id, 'album', response) unless @cache_disabled
      return JSON.parse(response)
    end
    def get_photo(album_id, photo_id)
      @request.set_form_data({'function' => 'getPhoto', 'albumID' => album_id, 'photoID' => photo_id, 'password' => ''})
      response = @http.request(@request).body
      cache(photo_id, 'photo', response) unless @cache_disabled
      return JSON.parse(response)
    end
  end

  class AlbumTagNoCache < AlbumTag
    def initialize(tag_name, config, token)
      super
      @cache_disabled = true
    end
  end
end

Liquid::Template.register_tag('album', Jekyll::AlbumTag)
Liquid::Template.register_tag('album_no_cache', Jekyll::AlbumTagNoCache)