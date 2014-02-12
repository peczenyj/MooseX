require 'moosex'

class TestMeta
  include MooseX.init(meta: true)

  has :foo
  has :bar, {
    is: :ro,
    default: 1,
    doc: "etc",
  }
end

class TestMeta2
  include MooseX.init(meta: :mymeta)

  has :foo
  has :bar, {
    is: :ro,
    default: 1,
    doc: "etc",
  }
end

describe TestMeta do
  it "should has 'meta'" do
    TestMeta.respond_to?(:meta).should be_true
  end

  it "meta should return list of attributes" do
    attrs = TestMeta.meta.attrs

    attributes = attrs.keys
    attributes[0].should == :foo
    attributes[1].should == :bar

    attrs[:foo].is.should == :rw

    attrs[:bar].is.should == :ro
    attrs[:bar].default.call.should == 1 
    attrs[:bar].doc.should == "etc"  
  end

  it "meta should return list of documentations" do
    docs = TestMeta.meta.info

    docs[:foo].should == ""
    docs[:bar].should == "etc"
  end

  it "TestMeta shuold be possible add an attribute on the fly" do
    TestMeta.has :baz, { required: true}
    tm = TestMeta.new(baz: 1)
    tm.baz.should == 1
    
    expect{
      TestMeta.new
    }.to raise_error(MooseX::InvalidAttributeError,
      'attr "baz" is required')
  end
end

describe TestMeta2 do
  it "should has 'mymeta'" do
    TestMeta2.respond_to?(:meta).should be_false
    TestMeta2.respond_to?(:mymeta).should be_true
  end

  it "meta should return list of attributes" do
    attrs = TestMeta2.mymeta.attrs

    attributes = attrs.keys
    attributes[0].should == :foo
    attributes[1].should == :bar

    attrs[:foo].is.should == :rw

    attrs[:bar].is.should == :ro
    attrs[:bar].default.call.should == 1 
    attrs[:bar].doc.should == "etc"  
  end

  it "meta should return list of documentations" do
    docs = TestMeta2.mymeta.info

    docs[:foo].should == ""
    docs[:bar].should == "etc"
  end

end