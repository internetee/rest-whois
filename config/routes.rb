Rails.application.routes.draw do
  root 'root#index'
  resources :contact_requests, only: [:new, :create, :update, :show, :edit], param: :secret

  scope '/v1' do
    get ':name', to: 'whois_records#show', constraints: { name: /([^\/]+?)(?=\.json|\.html|$|\/)/ }
    post ':name', to: 'whois_records#show', constraints: { name: /([^\/]+?)(?=\.json|\.html|$|\/)/ }
  end
end
