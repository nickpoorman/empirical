# frozen_string_literal: true

if ENV["COVERAGE"] == "true"
	require "simplecov"

	SimpleCov.start do
		command_name "quickdraw"
		enable_coverage_for_eval
		enable_for_subprocesses true
		enable_coverage :branch
	end
end

Bundler.require :test

require "empirical"

Empirical.init(include: ["#{Dir.pwd}/**/*"], exclude: ["**/excluded.rb"])

# Route the repository's top-level `test` DSL into Quickdraw before the runner
# requires each `*.test.rb` file.
def test(description = nil, skip: false, &block)
	Quickdraw::Test.test(description, skip:, &block)
end

class Quickdraw::Test
	# Keep the historical helper name that this repository's tests already use.
	def assert_equal_ruby(actual, expected)
		assert_equivalent_ruby(actual, expected)
	end
end
