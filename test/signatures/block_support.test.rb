# frozen_string_literal: true

test "function with untyped block argument" do
	mod = Module.new do
		extend self

		fun example(&block) => String do
			raise ArgumentError, "block required" unless block
			block.call
		end
	end

	assert_equal "Hello", mod.example { "Hello" }

	assert_raises ArgumentError do
		mod.example
	end
end

test "function with typed positional argument and untyped block argument" do
	mod = Module.new do
		extend self

		fun example(name = String, &block) => String do
			raise ArgumentError, "block required" unless block
			block.call(name)
		end
	end

	assert_equal "Hello Alice", mod.example("Alice") { |name| "Hello #{name}" }

	assert_raises Empirical::TypeError do
		mod.example(1) { |name| name.to_s }
	end
end

test "function with untyped splats and block forwarding" do
	mod = Module.new do
		extend self

		def capture(*args, **kwargs, &block)
			[args, kwargs, block&.call]
		end

		fun example(*args, **kwargs, &block) => Array do
			capture(*args, **kwargs, &block)
		end
	end

	assert_equal [["alpha", 1], {name: "Alice"}, "done"], mod.example("alpha", 1, name: "Alice") { "done" }
end
