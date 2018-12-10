module CaptchaHelpers
  private

  def enable_captcha
    Recaptcha.configuration.skip_verify_env.delete('test')
  end

  def disable_captcha
    Recaptcha.configuration.skip_verify_env.push('test')
  end
  alias_method :solve_captcha, :disable_captcha

  def with_captcha_test_keys
    # Allow ReCaptcha reach Google
    WebMock.allow_net_connect!
    Recaptcha.with_configuration(site_key: '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI',
                                 secret_key: '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe') do
      yield
    end
    WebMock.disable_net_connect!(allow_localhost: true) # `allow_localhost` is required by Selenium
  end

  def assert_no_captcha
    assert_no_css '.captcha'
    assert_no_button 'Show full WHOIS info'
  end
end
