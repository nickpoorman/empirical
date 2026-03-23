# frozen_string_literal: true

test "yield with a required block" do
	mod = Module.new do
		extend self

		fun example => String do
			yield
		end
	end

	assert_equal "Hello", mod.example { "Hello" }

	assert_raises LocalJumpError do
		mod.example
	end
end

test "yield guarded by block_given?" do
	mod = Module.new do
		extend self

		fun example => String do
			if block_given?
				yield
			else
				"Hello"
			end
		end
	end

	assert_equal "Hello", mod.example
	assert_equal "Hi", mod.example { "Hi" }
end

test "yield with typed arguments" do
	mod = Module.new do
		extend self

		fun example(name = String) => String do
			yield(name)
		end
	end

	assert_equal "Hello Alice", mod.example("Alice") { |name| "Hello #{name}" }

	assert_raises Empirical::TypeError do
		mod.example(1) { |name| name.to_s }
	end

	assert_raises Empirical::TypeError do
		mod.example("Alice") { |_name| 1 }
	end
end

test "processing yield keeps the emitted keyword" do
	processed = Empirical.process(<<~RUBY, with: [Empirical::SignatureProcessor])
		fun example => String do
			yield(:ok) if block_given?
			"done"
		end
	RUBY

	assert_includes processed, "yield(:ok) if block_given?"
	assert !processed.include?("__yd_")
end
