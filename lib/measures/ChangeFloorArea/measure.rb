# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

# require_relative 'resources/functions'

class ChangeFloorArea < OpenStudio::Measure::ModelMeasure

  def name
    return "Change Floor Area"
  end

  def description
    return "This measure will change the floor area of a building multiplying by a user-defined number."
  end

  def modeler_description
    return "The floor area and associated vertices of the building surfaces will be changed."
  end

  # return a vector of arguments
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # make double argument for fa_fraction
    fa_fraction = OpenStudio::Measure::OSArgument.makeDoubleArgument("fa_fraction", true)
    fa_fraction.setDisplayName('Fractional increase (or decrease) in floor area')
    fa_fraction.setDefaultValue(1.0)
    args << fa_fraction

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Use the built-in error checking
    unless runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    fa_fraction = runner.getDoubleArgumentValue("fa_fraction", user_arguments)

    # Get all surfaces
    surfaces = model.getSurfaces

    runner.registerInfo("Number of surfaces: #{surfaces.size}")

    surfaces.each do |surface|
      runner.registerInfo("Surface Name: #{surface.name}")
    end

  end
end

# this allows the measure to be used by the application
ChangeFloorArea.new.registerWithApplication
