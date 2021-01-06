Rails.application.routes.draw do
  root 'home#index'
  resources :contact_requests, only: %i[new create update show edit],
                               param: :secret

  post 'contact_requests/redirect_to_main', controller: :contact_requests,
                                            action: :redirect_to_main,
                                            as: 'redirect_to_main'

  resources :whois_records, only: [] do
    collection do
      post :search
    end
  end

  scope '/v1' do
    post 'aws_sns/bounce' => 'bounce_back#bounce'
    whois_record_name_constraint = /([^\/]+?)(?=\.json|\.html|$|\/)/

    constraints name: whois_record_name_constraint do
      get ':name', to: 'whois_records#show', as: 'whois_record'
      post ':name', to: 'whois_records#show'
    end
  end
end
