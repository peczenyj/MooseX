module MooseX
  
  class FatalError < StandardError
  end  

  class RequiredMethodNotFoundError < NameError
  end

  class InvalidAttributeError < TypeError
  end
end