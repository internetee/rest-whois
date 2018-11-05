Rails.application.routes.draw do
  root 'home#index'
  resources :contact_requests, only: [:new, :create, :update, :show, :edit], param: :secret

  resources :whois_records, only: [] do
    collection do
      post :search
    end
  end

  scope '/v1' do
    whois_record_name_constraint = /([^\/]+?)(?=\.json|\.html|$|\/)/

    constraints name: whois_record_name_constraint do
      get ':name', to: 'whois_records#show', as: 'whois_record'
      post ':name', to: 'whois_records#show'
    end
  end
end
