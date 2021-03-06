require 'test_helper'

class CarryOutTest < Minitest::Test
  class Echo < CarryOut::Unit
    parameter :message
    def call; @message; end
  end

  def test_that_it_has_a_version_number
    refute_nil ::CarryOut::VERSION
  end

  def test_that_it_can_have_default_options
    CarryOut.configure do 
      search CarryOutTest
    end

    plan = CarryOut.plan do
      echo do
        message 'test'
        return_as :echo
      end
    end

    result = plan.call

    assert_equal 'test', result.artifacts[:echo]
  end

  def test_that_search_can_take_a_lambda
    CarryOut.configure do 
      search -> (name) { Echo }
    end

    plan = CarryOut.plan do
      echo do
        message 'test'
        return_as :echo
      end
    end

    result = plan.call

    assert_equal 'test', result.artifacts[:echo]
  end

  def test_that_it_can_cache_a_configuration
    plan = CarryOut.with_configuration(search: [ CarryOutTest ]).plan do
      echo do
        message 'test'
        return_as :echo
      end
    end

    result = plan.call

    assert_equal 'test', result.artifacts[:echo]
  end

  def test_that_runner_yields_to_a_block
    plan = CarryOut.plan do
      call Echo do
        message 'test'
        return_as :echo
      end
    end

    result = nil

    plan.call { |r| result = r }
    
    assert_equal 'test', result.artifacts[:echo]
  end

  def test_that_can_run_single_unit
    result = CarryOut.call_unit(Echo, message: 'test') do
      message context(:message)
      return_as :echo
    end

    assert_equal 'test', result.artifacts[:echo]
  end
end
