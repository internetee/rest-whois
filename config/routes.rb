Rails.application.routes.draw do
  root 'root#index'
  resources :contact_requests, only: [:new, :create, :show] do
  end

  get "contact_requests/:secret/edit", to: "contact_requests#edit"
  post "contact_requests/:secret", to: "contact_requests#update"

  scope '/v1' do
    get '*id', to: 'whois_records#show', constraints: { id: /([^\/]+?)(?=\.json|\.html|$|\/)/ }
    post '*id', to: 'whois_records#show', constraints: { id: /([^\/]+?)(?=\.json|\.html|$|\/)/ }
  end
end
