Rails.application.routes.draw do
  root 'root#index'
  get 'search', controller: :root, action: :search
  resources :contact_requests, only: [:new, :create, :update, :show, :edit], param: :secret

  scope '/v1' do
    get '*id', to: 'whois_records#show', constraints: { id: /([^\/]+?)(?=\.json|\.html|$|\/)/ }
    post '*id', to: 'whois_records#show', constraints: { id: /([^\/]+?)(?=\.json|\.html|$|\/)/ }
    post '', to: 'whois_records#show', as: :search_domain
  end
end
