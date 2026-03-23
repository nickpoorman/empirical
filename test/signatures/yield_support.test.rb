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

test "yield with block_given? and arguments" do
	mod = Module.new do
		extend self

		fun example => String do
			if block_given?
				yield(:ok)
			else
				"fallback"
			end
		end
	end

	assert_equal "fallback", mod.example
	assert_equal "ok", mod.example { |value| value.to_s }
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
	refute processed.include?("__yd_")
end

test "processed yield source compiles" do
	processed = Empirical.process(<<~RUBY, with: Empirical::PROCESSORS)
		fun example => String do
			yield(:ok) if block_given?
			"done"
		end
	RUBY

	assert_same RubyVM::InstructionSequence, RubyVM::InstructionSequence.compile(processed).class
end

test "plain ruby defs with yield remain valid" do
	processed = Empirical.process(<<~RUBY, with: Empirical::PROCESSORS)
		class PlainYield
			def example
				yield(:ok)
			end
		end
	RUBY

	eval(processed, binding, __FILE__, __LINE__)
	assert_equal "ok", PlainYield.new.example { |value| value.to_s }
end

test "yield sanitization leaves comments and strings alone" do
	processed = Empirical.process(<<~RUBY, with: Empirical::PROCESSORS)
		class CommentYield
			def example
				# yield should stay in comments
				"yield in string"
			end
		end
	RUBY

	assert_includes processed, "# yield should stay in comments"
	assert_includes processed, '"yield in string"'
	refute processed.include?("__yd_")
end
