# frozen_string_literal: true

test "method overloaded with positional arguments" do
	mod = Module.new do
		extend self

		overload fun example(input = String) => String do
			"Called with a string"
		end

		overload fun example(input = Integer) => String do
			"Called with an integer"
		end
	end

	assert_equal mod.example("Hi"), "Called with a string"
	assert_equal mod.example(42), "Called with an integer"

	assert_raises NoMatchingPatternError do
		mod.example(true)
	end
end

test "method overloaded with positional arguments with explicit receiver" do
	mod = Module.new do
		overload fun self.example(input = String) => String do
			"Called with a string"
		end

		overload fun self.example(input = Integer) => String do
			"Called with an integer"
		end
	end

	overload fun mod.example(input = Float) => String do
		"Called with a float"
	end

	assert_equal mod.example("Hi"), "Called with a string"
	assert_equal mod.example(42), "Called with an integer"
	assert_equal mod.example(3.14), "Called with a float"

	assert_raises NoMatchingPatternError do
		mod.example(true)
	end
end

test "method overloaded with untyped positional rest arguments" do
	mod = Module.new do
		extend self

		overload fun example(*args) => Array do
			[:rest, args]
		end

		overload fun example(input = String) => Array do
			[:string, input]
		end
	end

	assert_equal [:rest, []], mod.example
	assert_equal [:string, "alpha"], mod.example("alpha")
	assert_equal [:rest, [1, nil, :three]], mod.example(1, nil, :three)
end

test "method overloaded with typed positional rest arguments" do
	mod = Module.new do
		extend self

		overload fun example(args = [String]) => Array do
			[:typed_rest, args]
		end

		overload fun example(input = Integer) => Array do
			[:integer, input]
		end
	end

	assert_equal [:typed_rest, ["alpha", "beta"]], mod.example("alpha", "beta")
	assert_equal [:integer, 42], mod.example(42)

	assert_raises NoMatchingPatternError do
		mod.example("alpha", 42)
	end
end

test "method overloaded with untyped keyword rest arguments" do
	mod = Module.new do
		extend self

		overload fun example(**kwargs) => Hash do
			kwargs
		end

		overload fun example(input = String) => Hash do
			{input:}
		end
	end

	assert_equal({}, mod.example)
	assert_equal({input: "Alice"}, mod.example("Alice"))
	assert_equal({admin: true, age: nil}, mod.example(admin: true, age: nil))
end

test "method overloaded with typed keyword rest arguments" do
	mod = Module.new do
		extend self

		overload fun example(kwargs: {Symbol => Integer}) => Hash do
			kwargs
		end

		overload fun example(input = String) => Hash do
			{input:}
		end
	end

	assert_equal({score: 7, attempts: 2}, mod.example(score: 7, attempts: 2))
	assert_equal({input: "Alice"}, mod.example("Alice"))

	assert_raises NoMatchingPatternError do
		mod.example(score: "seven")
	end
end
