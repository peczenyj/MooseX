require 'simplecov'
SimpleCov.start do
	# add_filter '/spec/'

	add_group 'core', 'lib'
	add_group 'test', 'spec'
end
