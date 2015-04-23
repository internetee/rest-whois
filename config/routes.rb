Rails.application.routes.draw do
  get '/v1/*id', to: 'records#show'
  root 'root#index'
end
