Rest whois server
=================

Rest whois server

Installation
------------

### Rest whois  app 

Rest whois is based on Rails 4 installation (rbenv install is under Debian build doc)

Manual demo install and database setup:

    cd /home/registry
    git clone git@github.com:domify/rest-whois.git
    cd rest-whois
    rbenv local 2.2.1
    bundle
    cp config/application-example.yml config/application.yml # and edit it
    cp config/database-example.yml config/database.yml # and edit it
    bundle exec rake db:setup # for production, please follow deployment howto

