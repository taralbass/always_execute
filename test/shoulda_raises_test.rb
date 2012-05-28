require "helper"

class ShouldaRaisesTest < Test::Unit::TestCase
  class SomeError < StandardError; end
  class SomeOtherError < StandardError; end

  context ".raises" do
    setup do
      @raise_error = nil
      @object = stub(:do_something => nil)
    end

    execute do
      raise @raise_error.new("error!") if @raise_error
      @object.do_something
    end

    context "when the expected error is raised" do
      setup do
        @raise_error = SomeError
      end

      raises SomeError, "with no block"

      raises SomeError do
        assert @execute_result.is_a?(SomeError)
        assert_equal "error!", @execute_result.message
      end

      raises StandardError do
        assert @execute_result.is_a?(SomeError)
        assert_equal "error!", @execute_result.message
      end

      raises SomeError, SomeOtherError do
        assert @execute_result.is_a?(SomeError)
        assert_equal "error!", @execute_result.message
      end

      raises SomeOtherError, SomeError do
        assert @execute_result.is_a?(SomeError)
        assert_equal "error!", @execute_result.message
      end

      context "when no error is raised in a nested context" do
        setup do
          @raise_error = nil
        end

        should "not prevent normal should blocks from succeeding" do
          assert true
        end

        expects "not to interfere with normal expects blocks" do
          @object.expects(:do_something)
        end
      end
    end

    context "when no error is raised" do
      should "not prevent normal should blocks from succeeding" do
        assert true
      end

      expects "not to interfere with normal expects blocks" do
        @object.expects(:do_something)
      end
    end
  end

  def test_flunk_when_no_execute_block_is_provided
    Test::Unit::TestCase.context "no-execute context" do
      raises SomeError do
      end
    end

    test_name = "test: no-execute context should raise [ShouldaRaisesTest::SomeError]. "

    exception = assert_raises Test::Unit::AssertionFailedError do
      self.send(test_name)
    end

    assert_match /raises requires a corresponding execute block/, exception.message
  end

  def test_flunk_when_expected_error_is_not_raised
    Test::Unit::TestCase.context "empty-execute context" do
      execute do
        # do nothing
      end

      raises SomeError do
      end
    end

    test_name = "test: empty-execute context should raise [ShouldaRaisesTest::SomeError]. "

    exception = assert_raises Test::Unit::AssertionFailedError do
      self.send(test_name)
    end

    assert_match /\[ShouldaRaisesTest::SomeError\] expected but nothing was raised/, exception.message
  end

  def test_flunk_when_unexpected_error_is_raised
    Test::Unit::TestCase.context "raise-some-other-error context" do
      execute do
        raise SomeOtherError
      end

      raises SomeError do
      end
    end

    test_name = "test: raise-some-other-error context should raise [ShouldaRaisesTest::SomeError]. "

    exception = assert_raises Test::Unit::AssertionFailedError do
      self.send(test_name)
    end

    assert_match /\[ShouldaRaisesTest::SomeError\] exception expected, not ShouldaRaisesTest::SomeOtherError/, exception.message
  end

  def test_correct_test_name_set_without_qualifier
    Test::Unit::TestCase.context "test-name-no-qualifier context" do
      execute do
      end

      raises SomeError do
      end
    end

    test_name = "test: test-name-no-qualifier context should raise [ShouldaRaisesTest::SomeError]. "
    assert self.respond_to?(test_name.to_sym), "expected test \"#{test_name}\" to be defined, but it wasn't"
  end

  def test_correct_test_name_set_with_qualifier
    Test::Unit::TestCase.context "test-name-with-qualifier context" do
      execute do
        # do nothing
      end

      raises SomeError, "but it won't" do
      end
    end

    test_name = "test: test-name-with-qualifier context should raise [ShouldaRaisesTest::SomeError] but it won't. "
    assert self.respond_to?(test_name.to_sym), "expected test \"#{test_name}\" to be defined, but it wasn't"
  end

  def test_raises_block_is_executed
    error = SomeError.new

    Test::Unit::TestCase.context "with-raises-block context" do
      execute do
        raise error
      end

      raises SomeError do
        @execute_result.do_something
      end
    end

    test_name = "test: with-raises-block context should raise [ShouldaRaisesTest::SomeError]. "

    error.expects(:do_something)
    self.send(test_name)
  end
end
