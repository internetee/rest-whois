26.03.2019
* Fixed handling domains at auction in json view [#192](https://github.com/internetee/rest-whois/pull/192)

25.03.2019
* Rails update to 5.2.2.1 [#188](https://github.com/internetee/rest-whois/pull/188)
* Added statuses for domainauctions [#182](https://github.com/internetee/rest-whois/pull/182)

11.02.2019
* Enable user disclosable attributes [#174](https://github.com/internetee/rest-whois/pull/174)
* Refactor disclosable contact attributes - blocked and reserved domain handling [#179](https://github.com/internetee/rest-whois/pull/179)
* Fixed language switch error in registrant contact form [#184](https://github.com/internetee/rest-whois/pull/184)
* Second click on unique registrant contact form link directs users to new search form with proper notification [#186](https://github.com/internetee/rest-whois/pull/186)
* Added build padge to github rest-whois project [#178](https://github.com/internetee/rest-whois/pull/178)
* Support system tests [#169](https://github.com/internetee/rest-whois/pull/169)

06.12.2018
* Rails upgrade to 5.2.1.1 [#167](https://github.com/internetee/rest-whois/pull/167)
* Removed duplicate Json keys [#140](https://github.com/internetee/rest-whois/pull/140)
* Removed unused disclose Json key [#163](https://github.com/internetee/rest-whois/pull/163)
* Removed unused `whois_records.body` DB column [#161](https://github.com/internetee/rest-whois/pull/161)
* Removed SyslogLogger gem [#134](https://github.com/internetee/rest-whois/pull/134)

08.11.2018
* Ruby upgrade to 2.5.3 [#160](https://github.com/internetee/rest-whois/pull/160)
* Rack upgrade to 2.0.6 (cve-2018-16470, cve-2018-16471) [#206](https://github.com/internetee/rest-whois/pull/158)
* Loofah upgrade to 2.2.3 (CVE-2018-16468) [#132](https://github.com/internetee/rest-whois/pull/132)
* disallowed rest-whois queries to be indexed [#136](https://github.com/internetee/rest-whois/pull/136)
* Test Fixes [#138](https://github.com/internetee/rest-whois/pull/138)
* Typo fix in status messages [#129](https://github.com/internetee/rest-whois/pull/129)
* Dockerfile update [#162](https://github.com/internetee/rest-whois/pull/162)
* CodeClimate config update [#130](https://github.com/internetee/rest-whois/pull/130)
* Use `t` instead of `I18n.t` [#126](https://github.com/internetee/rest-whois/pull/126)
* Disabled translation of available locales [#124](https://github.com/internetee/rest-whois/pull/124)
* Test env logs missing translation errors [#135](https://github.com/internetee/rest-whois/pull/135)
* Assets added to gitignore [#125](https://github.com/internetee/rest-whois/pull/125)
* Removed sass gem [#127](https://github.com/internetee/rest-whois/pull/127)

15.10.2018
* Nokogiri update to 1.8.5 [#121](https://github.com/internetee/rest-whois/pull/121)

05.09.2018
* Rails upgrade to 5.2.1 [#116](https://github.com/internetee/rest-whois/pull/116)
* Ruby upgrade to 2.4.4 [#117](https://github.com/internetee/rest-whois/pull/117)

06.07.2018
* Rails updgrade to 5.2 [#111](https://github.com/internetee/rest-whois/pull/111)
* Pg gem upgrade to 1.0 [#112](https://github.com/internetee/rest-whois/pull/112)
* Additional improvements to SMTP error logging [#53](https://github.com/internetee/rest-whois/issues/53) / [#110](https://github.com/internetee/rest-whois/pull/110)

02.07.2018
* Improved SMTP error handling on invalid email address in contact registrant form [#53](https://github.com/internetee/rest-whois/issues/53)

27.06.2018
* Domain registrations with contact request records are now released at delete_at date [#103](https://github.com/internetee/rest-whois/issues/103)

26.06.2018
* Email address confirmation emails are now localised depneding on UI language setting (email in 1 language instear of three) [#91](https://github.com/internetee/rest-whois/issues/91)
* Link in the email address confirmation form points now to the contact form in respective language [#84](https://github.com/internetee/rest-whois/issues/84)
* GDPR disclaimer is brough from bottom to top in the forwarded email template [#92](https://github.com/internetee/rest-whois/issues/92)
* Contact private registrant link is moved behind captcha [#72](https://github.com/internetee/rest-whois/issues/72)
* Contact registrant fuctionality now uses separate db instance and whosi data comes from read-only db [#93](https://github.com/internetee/rest-whois/issues/93)
* Rails updated to 5.0.7 [#85](https://github.com/internetee/rest-whois/issues/85)
* Sprockets gem updated to 3.7.2 [#99](https://github.com/internetee/rest-whois/pull/99)
* docker config added [#95](https://github.com/internetee/rest-whois/pull/95)

12.06.2018
* added search bar for rest-whois html view [#77](https://github.com/internetee/rest-whois/pull/77)
* UI fixes in private registrant contact forms [#54](https://github.com/internetee/rest-whois/issues/54)
* Spelled out internationalisation options in registrant contact forms [#73](https://github.com/internetee/rest-whois/issues/73)
* Return error 404 for requests and reserver/blocked/deleteCandidate domains [#86](https://github.com/internetee/rest-whois/pull/86)
* add Puma gem and config [#88](https://github.com/internetee/rest-whois/issues/88)
* removed Rubocop gem [#83](https://github.com/internetee/rest-whois/pull/83)
* Rails version update to 4.2.10 [#87](https://github.com/internetee/rest-whois/pull/87)
* ES6 compression enabled [#81](https://github.com/internetee/rest-whois/pull/81)
* config fix for staging environment [#82](https://github.com/internetee/rest-whois/pull/82)

31.05.2018
* Estonian language default in private registrant contact forms [#74](https://github.com/internetee/rest-whois/issues/74)
* Remove duplicate email addresses from email headers [#65](https://github.com/internetee/rest-whois/issues/65)
* Ruby version update to 2.3.7 [#55](https://github.com/internetee/rest-whois/issues/55)

25.05.2018
* GDPR - eraisikust registreeringu andmete peitmine [#37](https://github.com/internetee/rest-whois/issues/37)
* GDPR - moved admin and tech contact details for business registrations behind recaptcha [#38](https://github.com/internetee/rest-whois/issues/38)
* GDPR - eraisikutest regsitreerijatele kontakti saamise võimaluse vahendamine [#50](https://github.com/internetee/rest-whois/pull/50)
* GDPR - whitelist based suport for law enforcement agencys [#39](https://github.com/internetee/rest-whois/issues/39)
* added Travis CI [#42](https://github.com/internetee/rest-whois/pull/42)
* recpatcha gem update to version 4.8.0 [#47](https://github.com/internetee/rest-whois/issues/47)
* Nokogiri gem update to version 1.8.1 [#33](https://github.com/internetee/rest-whois/pull/33)
* remove newrelic gem [#43](https://github.com/internetee/rest-whois/pull/43)
* removed domains tabel from whois db [#48](https://github.com/internetee/rest-whois/pull/48)

30.01.2017

* Ruby version updated to 2.2.6

14.07.2016

* custom log entry logged on warn loglevel

15.06.2016

* added SyslogLogger

21.12.2015

* whitelist_ip new config param for no-captcha

26.05.2015

* Updated deploy script, now staging comes from staging branch
* Added NewRelic config to application-example.yml file

12.05.2015

* Ruby version updated to 2.2.2

24.04.2015

* Update config/application.yml with your recaptia api keys
