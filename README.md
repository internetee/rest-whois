Rest whois server
=================

Rest whois server

Examlpe usege:

1) html request, GET:

    /v1/example.ee

2) json request, GET:

    /v1/example.ee.json

By default there will return only public info.
If you need full whois info, user needs to use Google ReCaptchia, example usage:

1) html for full whois info, GET: 
    
    /v1/test.ee?utf8=%E2%9C%93&g-recaptcha-response=03AHJ_VuvVgYnzxXAuf8rdHvTPQ5FZSHYZ...

2) json for full whois info, GET:

    /v1/example.ee.json?utf8=%E2%9C%93&g-recaptcha-response=03AHJ_VuvY4cI_oBaP1BtercOD...


Installation
------------

Rest whois is based on Rails 4

Manual demo install and database setup:

    git clone git@github.com:domify/rest-whois.git
    cd rest-whois
    rbenv local 2.2.1
    bundle
    cp config/application-example.yml config/application.yml # and edit it
    cp config/database-example.yml config/database.yml # and edit it
    bundle exec rake db:setup # for production, please follow deployment howto

