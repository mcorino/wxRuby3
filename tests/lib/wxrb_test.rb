# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require 'minitest'
require 'minitest/autorun'

module Minitest

  module Assertions

    alias :assert_block :assert

    alias :assert_raise :assert_raises

    def assert_nothing_raised(&block)
      yield
    end

    def assert_true(test, msg = nil)
      assert(test == true, msg || "Expected #{mu_pp test} to be true.")
    end

    def assert_false(test, msg = nil)
      assert(test == false, msg || "Expected #{mu_pp test} to be false.")
    end

    def assert_not_nil(test, msg = nil)
      assert(!test.nil?, msg || "Expected #{mu_pp test} to be not nil.")
    end

    def assert_all?(enum, msg = nil)
      assert(enum.all? { |e| yield(e) }, msg)
    end

    def assert_not_empty(obj, msg = nil)
      assert_respond_to obj, :empty?, include_all:true
      assert(!obj.empty?, msg || "Expected #{mu_pp obj} to be not empty.")
    end

    def assert_not_equal(exp, act, msg = nil)
      assert(!(exp == act), msg || "Expected #{mu_pp act} to be not equal to #{mu_pp exp}.")
    end

    def assert_not_kind_of(cls, obj, msg = nil)
      msg = message(msg) {
        "Expected #{mu_pp obj} to not be a kind of #{cls}"
      }
      assert !obj.kind_of?(cls), msg
    end

    def assert_boolean(val, msg = nil)
      assert(val==true || val==false, msg || "Expected #{mu_pp val} to be true or false.")
    end

  end

end
