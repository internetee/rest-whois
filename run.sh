# docker build --no-cache -t ghcr.io/internetee/rest-whois:v1 -f Dockerfile.generic .
docker run -d \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_USERNAME=postgres \
  -e POSTGRES_DB=postgres \
  -p 5433:5432 --name db-r --network=test-net postgres:13.2
sleep 5
docker run -d \
  -e RAILS_ENV=test \
  -e APP_DBHOST=db-r \
  -e PG_USER=postgres \
  -e PG_PASSWORD=password \
  -e PG_DATABASE=postgres \
  -e recaptcha_site_key='6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI' \
  -e recaptcha_secret_key='6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe' \
  --name rest-whois --network=test-net ghcr.io/internetee/rest-whois:v1 tail -f /dev/null

          