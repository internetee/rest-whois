Rails.application.routes.draw do
  get '/v1/*id', to: 'whois_records#show', constraints: { id: /([^\/]+?)(?=\.json|\.html|$|\/)/ }
  post '/v1/*id', to: 'whois_records#show', constraints: { id: /([^\/]+?)(?=\.json|\.html|$|\/)/ }
  root 'root#index'
end
