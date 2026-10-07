require 'test_helper'

class PaypalCaTest < Test::Unit::TestCase
  def test_should_use_test_signature_endpoint
    gateway = PaypalCaGateway.new(login: 'cody', password: 'test', signature: 'SIG')

    assert_equal 'https://api-3t.sandbox.paypal.com/2.0/', gateway.send(:endpoint_url)
  end

  def test_should_use_live_signature_endpoint
    gateway = PaypalCaGateway.new(login: 'cody', password: 'test', signature: 'SIG')
    gateway.expects(:test?).returns(false)

    assert_equal 'https://api-3t.paypal.com/2.0/', gateway.send(:endpoint_url)
  end
end
