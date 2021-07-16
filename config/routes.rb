Rails.application.routes.draw do
  get '/api/ping', to: 'api#ping'
  get '/api/posts', to: 'api#show'
end
