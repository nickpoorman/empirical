# frozen_string_literal: true

test "yield assignment forms" do
	mod = Module.new do
		extend self

		fun example => Array do
			plain = yield(:plain)
			conditional = "fallback"
			conditional = yield(:conditional) if block_given?
			or_value = nil
			or_value ||= yield(:or)
			and_value = "seed"
			and_value &&= yield(:and)
			[plain, conditional, or_value, and_value]
		end
	end

	assert_equal ["plain", "conditional", "or", "and"], mod.example { |value| value.to_s.delete_prefix(":") }
end

test "yield with keyword arguments" do
	mod = Module.new do
		extend self

		fun example => String do
			yield(name: "Alice")
		end
	end

	assert_equal "Alice", mod.example { |name:| name }
end

test "yield with splat and keyword splat arguments" do
	mod = Module.new do
		extend self

		fun example(*args, **kwargs, &block) => Array do
			yield(*args, **kwargs)
		end
	end

	assert_equal [["alpha", 1], {name: "Alice"}], mod.example("alpha", 1, name: "Alice") { |*args, **kwargs| [args, kwargs] }
end

test "yield in collection and interpolation contexts" do
	mod = Module.new do
		extend self

		fun example => Hash do
			{
				array: [yield(:array)],
				message: "value=#{yield(:text)}"
			}
		end
	end

	assert_equal({array: ["array"], message: "value=text"}, mod.example { |value| value.to_s })
end

test "yield in ternary expressions" do
	mod = Module.new do
		extend self

		fun example => String do
			block_given? ? yield(:ok) : "fallback"
		end
	end

	assert_equal "fallback", mod.example
	assert_equal "ok", mod.example { |value| value.to_s }
end

test "yield in begin ensure" do
	mod = Module.new do
		extend self

		fun example => Array do
			calls = []

			begin
				calls << yield(:ok)
			ensure
				calls << :ensure
			end

			calls
		end
	end

	assert_equal ["ok", :ensure], mod.example { |value| value.to_s }
end

test "yield inside nested blocks" do
	mod = Module.new do
		extend self

		fun example => Array do
			[1].map { yield(:ok) }
		end
	end

	assert_equal ["ok"], mod.example { |value| value.to_s }
end

test "yield can be called multiple times" do
	mod = Module.new do
		extend self

		fun example => Array do
			[yield(:first), yield(:second)]
		end
	end

	assert_equal ["first", "second"], mod.example { |value| value.to_s }
end

test "instance methods can yield" do
	klass = Class.new do
		fun example => String do
			yield(:ok)
		end
	end

	assert_equal "ok", klass.new.example { |value| value.to_s }
end

test "private fun methods can yield" do
	klass = Class.new do
		private fun example => String do
			yield(:ok)
		end

		def call(&block)
			example(&block)
		end
	end

	assert_equal "ok", klass.new.call { |value| value.to_s }
end

test "overloaded fun methods forward yielded blocks" do
	mod = Module.new do
		extend self

		overload fun example(input = String) => String do
			yield(input)
		end

		overload fun example(input = Integer) => String do
			yield(input.to_s)
		end
	end

	assert_equal "string:Alice", mod.example("Alice") { |value| "string:#{value}" }
	assert_equal "integer:42", mod.example(42) { |value| "integer:#{value}" }
end

test "return yield with the correct type" do
	mod = Module.new do
		extend self

		fun example => String do
			return yield(:ok)
		end
	end

	assert_equal "ok", mod.example { |value| value.to_s }
end

test "return yield still validates the method return type" do
	mod = Module.new do
		extend self

		fun example => String do
			return yield(:ok)
		end
	end

	assert_raises Empirical::TypeError do
		mod.example { |_value| 1 }
	end
end
