require 'moosex'
require 'weakref'

class WeakRefExample
	include MooseX

	has a: { is: :rw, weak: true }
	has b: { is: :rw, weak: true, default: lambda{ Object.new } }
	has c: { is: :lazy, weak: true, clearer: true }

	def build_c
		Object.new
	end
end

describe WeakRefExample do
	it "should store an object as a weak reference in :a" do
		e = WeakRefExample.new(a: Object.new)

		e.a.class.should == WeakRef
	end

	it "should store an object as a weak reference via writter in :a" do
		e = WeakRefExample.new

		e.a = Object.new
		e.a.class.should == WeakRef
	end

	it "should store the default value as a weak reference in :b" do
		e = WeakRefExample.new

		e.b.class.should == WeakRef
	end

	it "should store a lazy value as a weak reference in :c" do
		e = WeakRefExample.new

		e.c.class.should == WeakRef
		e.clear_c!
		e.c.class.should == WeakRef
	end
end
