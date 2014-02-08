#require 'simplecov'
#SimpleCov.start do
#	# add_filter '/spec/'
#
#	add_group 'core', 'lib'
#	add_group 'test', 'spec'
#end
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '/spec/'
end
# Coveralls.wear!
