Hcaptcha.configure do |config|
  config.site_key  = ENV['hcaptcha_site_key']
  config.secret_key = ENV['hcaptcha_secret_key']

  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
  # Uncomment if you want to use the newer version of the API,
  # only works for versions >= 0.3.7:
end