# frozen_string_literal: true

class Empirical::BaseProcessor < Prism::Visitor
	EVAL_METHODS = Set[:class_eval, :module_eval, :instance_eval, :eval].freeze

	def initialize(annotations:, source: nil)
		@context = Set[]
		@annotations = annotations
		@source = source
	end
end
