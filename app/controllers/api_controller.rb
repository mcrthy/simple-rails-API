require 'net/http'
require 'json'
require 'concurrent'

class ApiController < ApplicationController

  BLOG_ENDPOINT = 'https://api.hatchways.io/assessment/blog/posts'

  POST_QUERY_PARAMS = {
    sortBy: [
      'id',
      'reads',
      'likes',
      'popularity'
    ],
    direction: [
      'asc',
      'dsc'
    ]
  }

  # GET /api/ping
  def ping
    json_response({'success': true}, 200)
  end

  # GET /api/posts
  def show
    
    threads = []

    # Thread-safe array
    result = Concurrent::Array.new

    @safe_params = params.permit(:tags, :sortBy, :direction)

    tags = @safe_params.require(:tags).split(',')
    sort_field = validate(:sortBy)
    sort_direction = validate(:direction)

    tags.each { |tag|
      threads << Thread.new do
          uri = URI("#{ApiController::BLOG_ENDPOINT}?tag=#{tag}")

          # caching result of API call
          res = Rails.cache.fetch(tag, expires_in: 12.hours) do   
            Net::HTTP.get_response(uri)
          end 

          data = JSON.parse(res.body)['posts']
          result |= data
        end
    }

    threads.each { |thread| thread.join }

    result.sort_by!{ |post| post[sort_field] }
      
    if sort_direction == 'dsc'
      result.reverse!
    end

    json_response({'posts': result})
  end

  private

  def validate(param)
    val = @safe_params[param]

    if val.nil?
      return ApiController::POST_QUERY_PARAMS[param][0]
    end

    if ApiController::POST_QUERY_PARAMS[param].include? val
      return val
    end

    raise(ExceptionHandler::InvalidParam, Message.invalid_param(param, val))
  end
end