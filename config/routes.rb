Rails.application.routes.draw do
  get '/v1/*id', to: 'whois_records#show'
  post '/v1/*id', to: 'whois_records#show'
  root 'root#index'
end
