Rails.application.routes.draw do
  whois_record_name_constraint = /([^\/]+?)(?=\.json|\.html|$|\/)/
  root 'root#index'
  resources :contact_requests, only: [:new, :create, :update, :show, :edit], param: :secret

  resources :whois_records, only: [] do
    collection do
      post :search
    end
  end

  scope '/v1' do
    get ':name', to: 'whois_records#show', constraints: { id: whois_record_name_constraint }
    post ':name', to: 'whois_records#show', constraints: { id: whois_record_name_constraint }
  end
end
