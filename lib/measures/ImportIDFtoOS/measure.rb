# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

# see the URL below for information on how to write OpenStudio measures
# http://openstudio.nrel.gov/openstudio-measure-writing-guide

# see your EnergyPlus installation or the URL below for information on EnergyPlus objects
# http://apps1.eere.energy.gov/buildings/energyplus/pdfs/inputoutputreference.pdf

# see the URL below for information on using life cycle cost objects in OpenStudio
# http://openstudio.nrel.gov/openstudio-life-cycle-examples

# see the URL below for access to C++ documentation on workspace objects (click on "workspace" in the main window to view workspace objects)
# http://openstudio.nrel.gov/sites/openstudio.nrel.gov/files/nv_data/cpp_documentation_it/utilities/html/idf_page.html

# start the measure
class ImportIDFToOS < OpenStudio::Measure::EnergyPlusMeasure
  # define the name that a user will see, this method may be deprecated as
  # the display name in PAT comes from the name field in measure.xml
  def name
    return "Import IDF to OS"
  end

  def description
    return "This measure allows you to import an IDF file to Openstudio without further process"
  end

  def modeler_description
    return "This measure allows the user to import an IDF file to Openstudio without editing. User may require to import weather file only.
    Openstudio can not import HVAC and other objects. This measure will make sure that all IDF objects are imported"  
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Ruleset::OSArgumentVector.new

    # make an argument for external idf
    source_idf_path = OpenStudio::Ruleset::OSArgument.makeStringArgument('source_idf_path', true)
    source_idf_path.setDisplayName('IDF File Name')
    source_idf_path.setDescription('The idf file to be imported')
    args << source_idf_path

    return args
  end

  # define what happens when the measure is run
  def run(workspace, runner, user_arguments)
    super(workspace, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(workspace), user_arguments)
      return false
    end

    # assign the user inputs to variables
    source_idf_path = runner.getStringArgumentValue('source_idf_path', user_arguments)

    # report initial condition
    runner.registerInitialCondition("The initial IDF file had #{workspace.objects.size} objects.")

    # find source_idf_path
    osw_file = runner.workflow.findFile(source_idf_path)
    if osw_file.is_initialized
      source_idf_path = osw_file.get.to_s
    else
      runner.registerError("Did not find #{source_idf_path} in paths described in OSW file.")
      return false
    end

    # load IDF
    source_idf = OpenStudio::IdfFile.load(OpenStudio::Path.new(source_idf_path)).get

    # add everything from the file
    workspace.addObjects(source_idf.objects)

    # List of objects to exclude
    excluded_object_types = [
      "Building",
      "GlobalGeometryRules",
      "HeatBalanceAlgorithm",
      "LifeCycleCost:Parameters",
      "Output:SQLite",
      "Output:Table:SummaryReports",
      "OutputControl:Table:Style",
      "ShadowCalculation",
      "SimulationControl",
      "Site:Location",
      "Sizing:Parameters",
      "Timestep"
    ]

    excluded_object_types.each do |object_type|
      objects = workspace.getObjectsByType(object_type.to_IddObjectType)
      if objects.size > 1
        # Remove all but the first object of this type
        objects[1..-1].each do |obj|
          obj.remove
        end
      end
    end


    # report final condition
    runner.registerFinalCondition("The final IDF file had #{workspace.objects.size} objects.")

    return true
  end
end

# this allows the measure to be use by the application
ImportIDFToOS.new.registerWithApplication
