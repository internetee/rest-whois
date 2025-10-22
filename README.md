Estonian Internet Foundation's REST WHOIS Server
=================
[![Maintainability](https://qlty.sh/gh/internetee/projects/rest-whois/maintainability.svg)](https://qlty.sh/gh/internetee/projects/rest-whois)
[![Code Coverage](https://qlty.sh/gh/internetee/projects/rest-whois/coverage.svg)](https://qlty.sh/gh/internetee/projects/rest-whois)


## Example usage

### HTML Request
* GET: `/v1/example.ee`

### JSON Request
* GET: `/v1/example.ee.json`

By default, this will return only public information. If full WHOIS info is required, the user needs to use Google ReCaptcha. Example usage:

### HTML for the Full WHOIS Info
* GET: `/v1/test.ee?utf8=%E2%9C%93&g-recaptcha-response=03AHJ_VuvVgYnzxXAuf8rdHvTPQ5FZSHYZ...`

### JSON for the Full WHOIS Info
* GET: `/v1/example.ee.json?utf8=%E2%9C%93&g-recaptcha-response=03AHJ_VuvY4cI_oBaP1BtercOD...`

Installation
------------

REST WHOIS is based on Rails 4.

## Manual demo installation

    git clone https://github.com/internetee/rest-whois/
    cd rest-whois
    rbenv local 2.3.7
    bundle install
    cp config/application-example.yml config/application.yml # and edit it
    cp config/database-example.yml config/database.yml # and edit it
    bundle exec rake db:setup # for production, please follow deployment howto


## Deployment
----------

    cd rest-whois
    mina pr setup
    edit shared/config/application.yml and shared/config/database.yml files

## Add apache config file:

```
<VirtualHost *:80>
  ServerName your-rest-whois.ee

  PassengerRoot /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini
  PassengerRuby /home/registry/.rbenv/shims/ruby
  PassengerEnabled on
  PassengerMinInstances 10
  PassengerMaxPoolSize 10
  PassengerPoolIdleTime 0
  PassengerMaxRequests 1000

  RailsEnv production # or staging
  DocumentRoot /home/registry/rest-whois/current/public

  # Possible values include: debug, info, notice, warn, error, crit,
  LogLevel info
  ErrorLog /var/log/apache2/rest-whois.error.log
  CustomLog /var/log/apache2/rest-whois.access.log combined

  <Directory /home/registry/rest-whois/current/public>
    # for Apache older than version 2.4
    Allow from all

    # for Apache verison 2.4 or newer
    # Require all granted

    Options -MultiViews
  </Directory>
</VirtualHost>
```

## Deploying from your machine:

    mina pr deploy

## Database
----------
The database is shared, and all operations take place in the registry project. It is not recommended to perform operations or migrations within the framework of rest-whois.
