# Author:: Roy Miller, Duff O'Melia.
# Copyright:: Copyright (c) 2002 RoleModel Software, Inc. All rights reserved.
# License:: Ruby license.

class Sham
  include Test::Unit::Assertions

  def initialize( name = self.to_s )
    @name = name
    @definedMethods = { }
    @calledMethods = Hash.new(0)
    @parametersPassedToMethod = Hash.new([])
  end
  
  public
  def defineShamMethodOnCallNumber( methodSymbol, callNumber, &methodDefinition )
    @definedMethods[ [methodSymbol, callNumber] ] = (methodDefinition.nil?) ? Proc.new { } : methodDefinition
  end
  
  public     
  def defineShamMethod( methodSymbol, &methodDefinition )
    if (!methodSymbol.kind_of?(Symbol))
      raise ArgumentError.new("Attempted to define a sham method with a non-symbol named '#{methodSymbol}'")
    end
    
    @calledMethods.delete(methodSymbol)
    @definedMethods[methodSymbol] = (methodDefinition.nil?) ? Proc.new { } : methodDefinition
  end
  
  private
  def methodDefinition(methodSymbol, currentCallNumber)
    definition = @definedMethods[ [methodSymbol, currentCallNumber] ]
    if (definition.nil?)
      definition = @definedMethods[methodSymbol]
    end   	
    
    definition
  end
  
  private
  def callDefinedMethod(methodSymbol, currentCallNumber, *args, &block)
    method = methodDefinition(methodSymbol, currentCallNumber)
    return if (!method)
    
    if (block_given?)
      method.call(block, *args)
    else
      method.call(*args)
    end
  end
  
  private
  def method_missing( methodSymbol, *args, &block )
    currentCallNumber = @calledMethods[methodSymbol] + 1
    
    @parametersPassedToMethod[ [methodSymbol, currentCallNumber] ] = args
    @calledMethods[methodSymbol] = currentCallNumber
    
    callDefinedMethod(methodSymbol, currentCallNumber, *args, &block)
  end
  
  public
  def assertMethodWasCalled(methodSymbol)
    assert(@calledMethods.include?(methodSymbol), "Expected the method named '#{methodSymbol}' to be called on the Sham named '#{@name}'.")
  end
  
  public
  def assertMethodWasNotCalled(methodSymbol)
    assert(!@calledMethods.include?(methodSymbol), "Did not expect the method named '#{methodSymbol}' to be called on the Sham named '#{@name}'.")
  end
  
  public
  def assertMethodWasCalledCertainNumberOfTimes(methodSymbol, expectedNumber)
    actualNumber = @calledMethods[methodSymbol]
    assert_equal(expectedNumber, actualNumber, "Should have called the method named '#{methodSymbol}' the correct number of times on the Sham named '#{@name}'.")
    @calledMethods[methodSymbol] = 0
  end
  
  public
  def assertMethodReceivedParameters(methodSymbol, expectedParameters)
    lastCallNumber = @calledMethods[methodSymbol]
    assertMethodReceivedParametersOnCallNumber(methodSymbol, lastCallNumber, expectedParameters)
  end
  
  public
  def assertMethodReceivedParametersOnCallNumber(methodSymbol, callNumber, expectedParameters)
    assertMethodWasCalled(methodSymbol)
    
    actualParameters = @parametersPassedToMethod[ [methodSymbol, callNumber] ]
    assert_equal(expectedParameters, actualParameters, "\nThe method named '#{methodSymbol}' on the Sham named '#{@name}' should have received the correct parameters")
  end
  
end



