required = %w(
  recaptcha_public_key
  recaptcha_private_key
)

Figaro.require_keys(required)
