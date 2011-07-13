# Author:: Roy Miller, Duff O'Melia
# Copyright:: Copyright (c) 2002 RoleModel Software, Inc. All rights reserved.
# License:: Ruby license.

require 'test/RublogTestCase'
require 'test/sham'

class TC_Sham < RublogTestCase

  private	
  def setup
    @sham = Sham.new("Sham")
  end
  
  public
  def testCallUndefinedMethod
    
    assert_nothing_raised("Should be able to call methods which have not been defined.") {
      @sham.undefinedMethod
    }
  end
  
  public
  def testCallDefinedMethod_WithoutArgs
    
    @sham.defineShamMethod(:definedMethod) {
      return "Return value from defined method."
    }
    
    returnValue = nil
    assert_nothing_raised("Should not raise an exception if the defined method is called on the sham.") {
      returnValue = @sham.definedMethod
    }		
    
    assert_equal("Return value from defined method.", returnValue, "The defined method should return the correct value.")
  end
  
  public
  def testCallDefined_MethodWithArgs
    
    @sham.defineShamMethod(:definedMethodWithArgs) { | argumentOne, argumentTwo |
      [ argumentOne, argumentTwo ]
    }
    
    returnValue = nil
    assert_nothing_raised("Should not raise an exception if the defined method is called on the sham.") {
      returnValue = @sham.definedMethodWithArgs(1, 2)
    }		
    
    assert_equal([ 1, 2 ], returnValue, "The defined method should receive the arguments.")
  end
  
  public 
  def testCallDefinedMethod_ParticularCallNumber
    @sham.defineShamMethodOnCallNumber(:definedMethod, 1) { "CallOne" }
    @sham.defineShamMethodOnCallNumber(:definedMethod, 2) { "CallTwo" }
    
    returnValue = nil
    assert_nothing_raised("Should not raise an exception if the defined method is called on the sham for call number 1.") {
      returnValue = @sham.definedMethod()
    }		
    assert_equal("CallOne", returnValue, "Should have used the appropriate method definition for call number 1.")
    
    assert_nothing_raised("Should not raise an exception if the defined method is called on the sham for call number 2.") {
      returnValue = @sham.definedMethod()
    }		
    assert_equal("CallTwo", returnValue, "Should have used the appropriate method definition for call number 2.")
  end
  
  public 
  def testCallDefinedMethod_ParticularCallOverridesDefaultBehavior
    @sham.defineShamMethod(:definedMethod) { "DefaultBehavior" }
    @sham.defineShamMethodOnCallNumber(:definedMethod, 2) { "CallTwo" }
    
    assert_equal("DefaultBehavior", @sham.definedMethod(), "Should have used the default method definition for call number 1.")
    assert_equal("CallTwo", @sham.definedMethod(), "Should have used the appropriate overidden method definition for call number 2.")
    assert_equal("DefaultBehavior", @sham.definedMethod(), "Should have used the default method definition again.")
  end
  
  public
  def testAssertMethodWasCalled
    @sham.methodThatShouldHaveBeenCalled		
    assert_nothing_raised("Sham should have said method was called.") {
      @sham.assertMethodWasCalled(:methodThatShouldHaveBeenCalled)
    }
    
    @sham.defineShamMethod(:methodThatShouldHaveBeenCalled) 
    assert_raises(Test::Unit::AssertionFailedError, "Sham should not have said method was called if it was redefined and not called again.") {
      @sham.assertMethodWasCalled(:methodThatShouldHaveBeenCalled)
    }
    
    assert_raises(Test::Unit::AssertionFailedError, "Sham should not have said method was called.") {
      @sham.assertMethodWasCalled(:methodThatShouldNotHaveBeenCalled)
    }
  end
  
  public
  def testAssertMethodWasNotCalled
    assert_nothing_raised("Sham should have said method was not called.") {
      @sham.assertMethodWasNotCalled(:methodThatShouldNotHaveBeenCalled)
    }
    
    @sham.methodThatShouldNotHaveBeenCalled		
    assert_raises(Test::Unit::AssertionFailedError, "Sham should have said method should not have been called.") {
      @sham.assertMethodWasNotCalled(:methodThatShouldNotHaveBeenCalled)
    }
  end
  
  public
  def testAssertMethodWasCalledCertainNumberOfTimes
    @sham.methodThatShouldHaveBeenCalledMultipleTimes
    @sham.methodThatShouldHaveBeenCalledMultipleTimes
    @sham.methodThatShouldHaveBeenCalledMultipleTimes
    assert_nothing_raised("Sham should have said method was called the right number of times.") {
      @sham.assertMethodWasCalledCertainNumberOfTimes(:methodThatShouldHaveBeenCalledMultipleTimes, 3)
    }
    
    @sham.methodThatShouldHaveBeenCalledMultipleTimes
    @sham.methodThatShouldHaveBeenCalledMultipleTimes
    assert_nothing_raised("Sham should have said method was called the right number of times.  The sham reset itself after checking last time.") {
      @sham.assertMethodWasCalledCertainNumberOfTimes(:methodThatShouldHaveBeenCalledMultipleTimes, 2)
    }
    
    @sham.methodThatShouldHaveBeenCalledMultipleTimes
    assert_raises(Test::Unit::AssertionFailedError, "Sham should not have said method was called the right number of times.  It was only called once.") {
      @sham.assertMethodWasCalledCertainNumberOfTimes(:methodThatShouldHaveBeenCalledMultipleTimes, 2)
    }
  end
  
  public
  def testAssertMethodReceivedParameters
    @sham.methodWithParameters(1, 2)
    assert_raises(Test::Unit::AssertionFailedError, "Should complain when method received wrong parameters.") {
      @sham.assertMethodReceivedParameters(:methodWithParameters, [ "Incorrect parameters" ])
    }
    
    assert_nothing_raised("Should NOT complain when method received correct parameters.") {
      @sham.assertMethodReceivedParameters(:methodWithParameters, [ 1, 2 ])
    }
    
  end
  
  public
  def testAssertMethodReceivedParametersOnCallNumber
    @sham.methodWithParameters(1, 2)
    @sham.methodWithParameters(3, 4)
    
    assert_raises(Test::Unit::AssertionFailedError, "Should complain when method received wrong parameters on 1st invocation.") {
      @sham.assertMethodReceivedParametersOnCallNumber(:methodWithParameters, 1, [ "Incorrect parameters" ])
    }
    
    assert_raises(Test::Unit::AssertionFailedError, "Should complain when method received wrong parameters on 2nd invocation.") {
      @sham.assertMethodReceivedParametersOnCallNumber(:methodWithParameters, 2, [ "Incorrect parameters" ])
    }
    
    assert_nothing_raised("Should NOT complain when method received correct parameters on 1st invocation.") {
      @sham.assertMethodReceivedParametersOnCallNumber(:methodWithParameters, 1, [ 1, 2 ])
    }
    
    assert_nothing_raised("Should NOT complain when method received correct parameters on 2nd invocation.") {
      @sham.assertMethodReceivedParametersOnCallNumber(:methodWithParameters, 2, [ 3, 4 ])
    }
  end
  
  public
  def testAssertMethodReceivedNoParameters
    @sham.methodWithoutParameters
    assert_raises(Test::Unit::AssertionFailedError, "Should complain when method received wrong parameters.") {
      @sham.assertMethodReceivedParameters(:methodWithoutParameters, [ "Incorrect parameters" ])
    }
    
    assert_nothing_raised("Should NOT complain when method received correct parameters.") {
      @sham.assertMethodReceivedParameters(:methodWithoutParameters, [  ])
    }
    
    @sham.defineShamMethod(:methodWithoutParametersThatWasNotCalled)
    assert_raises(Test::Unit::AssertionFailedError, "Should complain when checking parameters for method which wasn't called.") {
      @sham.assertMethodReceivedParameters(:methodWithoutParametersThatWasNotCalled, [  ])
    }
  end
  
  public
  def testDefineShamMethodWithNoBlock
    @sham.defineShamMethod(:methodWithNoBlock)
    
    assert_nothing_raised("Should not raise an exception when calling method that wasn't defined with a block.") {
      @sham.methodWithNoBlock
    }
  end
  
  public
  def testDefineShamMethodWithNonSymbol
    assert_raises(ArgumentError, "Should raise an exception if the defineShamMethod doesn't receive a Symbol.") {
      @sham.defineShamMethod("NonSymbol.Need a symbol") 
    }
  end
end
