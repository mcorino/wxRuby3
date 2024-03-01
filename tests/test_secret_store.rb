# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

require 'digest'

class TestSecretStore < Test::Unit::TestCase

  unless is_ci_build?

  def test_store
    if Wx.has_feature?(:USE_SECRETSTORE)
      state, err = Wx::SecretStore.get_default.ok?
      if state
        puts "SecretStore OK"

        if Wx::WXWIDGETS_VERSION > '3.2.4'
          password = Digest::SHA256.digest('My Secret Password!')
        else
          password = Digest::SHA256.hexdigest('My Secret Password!') # binary secrets does not work
        end
        secret_val = Wx::SecretValue.new(password)
        assert_true(Wx::SecretStore.get_default.save('My/Service', 'a_user', secret_val))

        secret_val2 = Wx::SecretValue.new
        rc, user = Wx::SecretStore.get_default.load('My/Service', secret_val2)
        assert_true(rc)
        assert_equal('a_user', user)
        assert_equal(secret_val, secret_val2)
        assert_equal(password, secret_val2.get_data)

        password = 'My Secret Password!'
        secret_val = Wx::SecretValue.new(password)
        assert_true(Wx::SecretStore.get_default.save('My/Service', 'a_user', secret_val))

        secret_val2 = Wx::SecretValue.new
        rc, user = Wx::SecretStore.get_default.load('My/Service', secret_val2)
        assert_true(rc)
        assert_equal('a_user', user)
        assert_equal(secret_val, secret_val2)
        assert_equal(password, secret_val2.get_as_string)

        password = 'My Secret Password!'.encode('UTF-16')
        secret_val = Wx::SecretValue.new(password)
        assert_true(Wx::SecretStore.get_default.save('My/Service', 'a_user', secret_val))

        secret_val2 = Wx::SecretValue.new
        rc, user = Wx::SecretStore.get_default.load('My/Service', secret_val2)
        assert_true(rc)
        assert_equal('a_user', user)
        assert_equal(secret_val, secret_val2)
        assert_equal(password, secret_val2.get_as_string)
        assert_not_equal('My Secret Password!'.encode('UTF-16'), secret_val2.get_as_string)
        assert_equal('My Secret Password!'.encode('UTF-16'), secret_val2.get_as_string.encode('UTF-16'))

        password = 'My Secret Password!'.encode('UTF-32')
        secret_val = Wx::SecretValue.new(password)
        assert_true(Wx::SecretStore.get_default.save('My/Service', 'a_user', secret_val))

        secret_val2 = Wx::SecretValue.new
        rc, user = Wx::SecretStore.get_default.load('My/Service', secret_val2)
        assert_true(rc)
        assert_equal('a_user', user)
        assert_equal(secret_val, secret_val2)
        assert_equal(password, secret_val2.get_as_string)
        assert_not_equal('My Secret Password!'.encode('UTF-32'), secret_val2.get_as_string)
        assert_equal('My Secret Password!'.encode('UTF-32'), secret_val2.get_as_string.encode('UTF-32'))

        assert_true(Wx::SecretStore.get_default.delete('My/Service'))

      else
        puts "Default SecretStore not usable : #{err}"
      end
    else
      puts 'Wx::SecretStore not available'
    end
  end

  end

end
