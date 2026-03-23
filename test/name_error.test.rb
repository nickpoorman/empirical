# frozen_string_literal: true

class NameErrorExample
	def initialize
		@username = 1
		@user = 2
		@user_favourites = 2
	end
end

test "suggestions" do
	assert_equal Empirical::NameError.new(NameErrorExample.new, :@use).message,
		"Undefined instance variable `@use`. Did you mean `@user`?"

	assert_equal Empirical::NameError.new(NameErrorExample.new, :@users).message,
		"Undefined instance variable `@users`. Did you mean `@user`?"

	assert_equal Empirical::NameError.new(NameErrorExample.new, :@usre).message,
		"Undefined instance variable `@usre`. Did you mean `@user`?"

	assert_equal Empirical::NameError.new(NameErrorExample.new, :@usrenam).message,
		"Undefined instance variable `@usrenam`. Did you mean `@username`?"

	assert_equal Empirical::NameError.new(NameErrorExample.new, :@userna).message,
		"Undefined instance variable `@userna`. Did you mean `@username`?"

	assert_equal Empirical::NameError.new(NameErrorExample.new, :@usrfavorits).message,
		"Undefined instance variable `@usrfavorits`. Did you mean `@user_favourites`?"
end
