class Shoulda::Context
  def raises(*args, &raises_block)
    expected_exceptions = args
    test_name_qualifier = args.last.is_a?(String) ? (' ' + args.pop) : ''

    context nil do
      setup do
        if @execute_block.nil?
          flunk "raises requires a corresponding execute block"
        end

        @old_execute_block = @execute_block

        @execute_block = lambda do
          begin
            @old_execute_block.bind(self).call
          rescue => exception
          end

          unless exception
            flunk "#{expected_exceptions.inspect} expected but nothing was raised"
          end

          exception
        end
      end

      should "raise #{expected_exceptions.inspect}#{test_name_qualifier}" do
        if expected_exceptions.none?{|ee| @execute_result.is_a?(ee)}
          flunk [
            "#{expected_exceptions.inspect} exception expected, not #{@execute_result.class.name}",
            "Message: #{@execute_result.message}",
            "---Backtrace---",
            "#{@execute_result.backtrace.join("\n")}",
            "---------------"
          ].join("\n")
        end

        raises_block.bind(self).call unless raises_block.nil?
      end
    end
  end
end

