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
class AddPCMtoEnv < OpenStudio::Measure::EnergyPlusMeasure
  # human readable name
  def name
    return "AddPCMtoEnv"
  end
  # human readable description
  def description
    return "This measure can create new material with phase change property from user inputs and edit the idf file to run simulation."
  end
  # human readable description of modeling approach
  def modeler_description
    return "This measure will replace heatbalance algorithm to CondFD, add new materials with phase change property and add the PCM material to a specific layer of any construction. "
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Measure::OSArgumentVector.new

    # the name of the zone to receive air
    time_step = OpenStudio::Measure::OSArgument.makeStringArgument('time_step', true)
    time_step.setDisplayName('Time step in an hour (Value should be equal or greater than 20)')
    args << time_step

    # Get all construction objects from the workspace
    constructions = workspace.getObjectsByType("Construction".to_IddObjectType)

    # Iterate over the constructions to find the target construction
    envelope_constructions = OpenStudio::StringVector.new
    constructions.each do |construction|
      name = construction.getString(0)
      envelope_constructions << name.get if name.is_initialized
    end

    # Name of the external wall or roof where PCM will be added
    # envelope_name = OpenStudio::Measure::OSArgument.makeStringArgument('envelope_name', true)
    envelope_name = OpenStudio::Measure::OSArgument.makeChoiceArgument('envelope_name', envelope_constructions, true)
    envelope_name.setDisplayName('Choose Construction where PCM is intended to add')
    # envelope_name.setDefaultValue('Typical Insulated Wood Framed Exterior Wall R-15.63')
    envelope_name.setDefaultValue("")
    args << envelope_name

    # PCM Material Arguments for 1st Construction
    pcm_index = OpenStudio::Measure::OSArgument.makeIntegerArgument('pcm_index', true)
    pcm_index.setDisplayName('1st PCM Layer Position')
    pcm_index.setDefaultValue(0)
    args << pcm_index

    # Name of the external wall or roof where PCM will be added
    # envelope_name = OpenStudio::Measure::OSArgument.makeStringArgument('envelope_name', true)
    envelope_name2 = OpenStudio::Measure::OSArgument.makeChoiceArgument('envelope_name2', envelope_constructions, false)
    envelope_name2.setDisplayName('(Optional): Choose another Construction where PCM is intended to add')
    envelope_name2.setDefaultValue("")
    args << envelope_name2

    # PCM Material Arguments for 2nd Construction
    pcm_index2 = OpenStudio::Measure::OSArgument.makeIntegerArgument('pcm_index2', false)
    pcm_index2.setDisplayName('2nd PCM Layer Position')
    pcm_index2.setDefaultValue(0)
    args << pcm_index2

    pcm_name = OpenStudio::Measure::OSArgument.makeStringArgument('pcm_name', true)
    pcm_name.setDisplayName('PCM Layer Name')
    pcm_name.setDefaultValue('PCMBoard')
    args << pcm_name
  
    pcm_thickness = OpenStudio::Measure::OSArgument.makeDoubleArgument('pcm_thickness', true)
    pcm_thickness.setDisplayName('PCM Layer Thickness (m)')
    pcm_thickness.setDefaultValue(0.01905)
    args << pcm_thickness
  
    pcm_cond = OpenStudio::Measure::OSArgument.makeDoubleArgument('pcm_cond', true)
    pcm_cond.setDisplayName('PCM Conductivity (W/m-k)')
    pcm_cond.setDefaultValue(0.7264224)
    args << pcm_cond
  
    pcm_den = OpenStudio::Measure::OSArgument.makeDoubleArgument('pcm_den', true)
    pcm_den.setDisplayName('PCM Density (kg/m3)')
    pcm_den.setDefaultValue(1601.846)
    args << pcm_den
  
    pcm_sp_heat = OpenStudio::Measure::OSArgument.makeDoubleArgument('pcm_sp_heat', true)
    pcm_sp_heat.setDisplayName('PCM Specific Heat (J/kg-k)')
    pcm_sp_heat.setDefaultValue(836.8000)
    args << pcm_sp_heat

    pcm_rough = OpenStudio::Measure::OSArgument.makeStringArgument('pcm_rough', false)
    pcm_rough.setDisplayName('Roughness')
    pcm_rough.setDefaultValue('Smooth')
    args << pcm_rough
  
    pcm_abs = OpenStudio::Measure::OSArgument.makeDoubleArgument('pcm_abs', false)
    pcm_abs.setDisplayName('PCM Thermal Absorptance')
    pcm_abs.setDefaultValue(0.9000)
    args << pcm_abs
  
    pcm_sol_abs = OpenStudio::Measure::OSArgument.makeDoubleArgument('pcm_sol_abs', false)
    pcm_sol_abs.setDisplayName('PCM Solar Absorptance')
    pcm_sol_abs.setDefaultValue(0.9200)
    args << pcm_sol_abs
  
    pcm_vis_abs = OpenStudio::Measure::OSArgument.makeDoubleArgument('pcm_vis_abs', false)
    pcm_vis_abs.setDisplayName('PCM Visible Absorptance')
    pcm_vis_abs.setDefaultValue(0.9200)
    args << pcm_vis_abs

    # PCM Phase Change Temperature and Enthalpy Arguments

    temp_coeff = OpenStudio::Measure::OSArgument.makeDoubleArgument('temp_coeff', false)
    temp_coeff.setDisplayName('Temperature coefficient')
    temp_coeff.setDefaultValue(0.01)
    args << temp_coeff

    temp1 = OpenStudio::Measure::OSArgument.makeDoubleArgument('temp1', true)
    temp1.setDisplayName('Temperature 1 (°C)')
    temp1.setDefaultValue(-20.0)
    args << temp1
  
    enthalpy1 = OpenStudio::Measure::OSArgument.makeDoubleArgument('enthalpy1', true)
    enthalpy1.setDisplayName('Enthalpy 1 (J/kg)')
    enthalpy1.setDefaultValue(0.0)
    args << enthalpy1
  
    temp2 = OpenStudio::Measure::OSArgument.makeDoubleArgument('temp2', true)
    temp2.setDisplayName('Temperature 2 (°C)')
    temp2.setDefaultValue(20.0)
    args << temp2
  
    enthalpy2 = OpenStudio::Measure::OSArgument.makeDoubleArgument('enthalpy2', true)
    enthalpy2.setDisplayName('Enthalpy 2 (J/kg)')
    enthalpy2.setDefaultValue(33400)
    args << enthalpy2
  
    temp3 = OpenStudio::Measure::OSArgument.makeDoubleArgument('temp3', true)
    temp3.setDisplayName('Temperature 3 (°C)')
    temp3.setDefaultValue(20.5)
    args << temp3
  
    enthalpy3 = OpenStudio::Measure::OSArgument.makeDoubleArgument('enthalpy3', true)
    enthalpy3.setDisplayName('Enthalpy 3 (J/kg)')
    enthalpy3.setDefaultValue(70000)
    args << enthalpy3
  
    temp4 = OpenStudio::Measure::OSArgument.makeDoubleArgument('temp4', true)
    temp4.setDisplayName('Temperature 4 (°C)')
    temp4.setDefaultValue(100.0)
    args << temp4
  
    enthalpy4 = OpenStudio::Measure::OSArgument.makeDoubleArgument('enthalpy4', true)
    enthalpy4.setDisplayName('Enthalpy 4 (J/kg)')
    enthalpy4.setDefaultValue(137000)
    args << enthalpy4


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
    time_step = runner.getStringArgumentValue('time_step', user_arguments)

    envelope_name = runner.getStringArgumentValue('envelope_name', user_arguments)
    pcm_index = runner.getIntegerArgumentValue('pcm_index', user_arguments)

    # set second envelope as optional in case it is empty
    optional_envelope_name2 = runner.getOptionalStringArgumentValue('envelope_name2', user_arguments)
    if optional_envelope_name2.is_initialized
      envelope_name2 = optional_envelope_name2.get
    else
      envelope_name2 = nil
    end
    # Get optional integer for the second PCM insertion
    optional_pcm_index2 = runner.getOptionalIntegerArgumentValue('pcm_index2', user_arguments)

    if optional_pcm_index2.is_initialized
      pcm_index2 = optional_pcm_index2.get
    else
      pcm_index2 = nil
    end

    pcm_name = runner.getStringArgumentValue('pcm_name', user_arguments)
    pcm_thickness = runner.getDoubleArgumentValue('pcm_thickness', user_arguments)
    pcm_cond = runner.getDoubleArgumentValue('pcm_cond', user_arguments)
    pcm_den = runner.getDoubleArgumentValue('pcm_den', user_arguments)
    pcm_sp_heat = runner.getDoubleArgumentValue('pcm_sp_heat', user_arguments)
    pcm_rough = runner.getStringArgumentValue('pcm_rough', user_arguments)
    pcm_abs = runner.getDoubleArgumentValue('pcm_abs', user_arguments)
    pcm_sol_abs = runner.getDoubleArgumentValue('pcm_sol_abs', user_arguments)
    pcm_vis_abs = runner.getDoubleArgumentValue('pcm_vis_abs', user_arguments)

    temp_coeff = runner.getDoubleArgumentValue('temp_coeff', user_arguments)
    temp1 = runner.getDoubleArgumentValue('temp1', user_arguments)
    enthalpy1 = runner.getDoubleArgumentValue('enthalpy1', user_arguments)
    temp2 = runner.getDoubleArgumentValue('temp2', user_arguments)
    enthalpy2 = runner.getDoubleArgumentValue('enthalpy2', user_arguments)
    temp3 = runner.getDoubleArgumentValue('temp3', user_arguments)
    enthalpy3 = runner.getDoubleArgumentValue('enthalpy3', user_arguments)
    temp4 = runner.getDoubleArgumentValue('temp4', user_arguments)
    enthalpy4 = runner.getDoubleArgumentValue('enthalpy4', user_arguments)


    # reporting initial condition of model
    ts_object = workspace.getObjectsByType('Timestep'.to_IddObjectType).first
    current_ts = ts_object.getString(0).to_s.to_i
    runner.registerInitialCondition("The initial timestep is #{current_ts}")

    if current_ts > 20
      ts_object.setString(0, time_step)  # Assuming time_step is a string like "6"
    end

    runner.registerFinalCondition("The final timestep is #{time_step}")


    # HeatBalanceAlgorithm
    hba = workspace.getObjectsByType('HeatBalanceAlgorithm'.to_IddObjectType).first
    unless hba.getString(0).to_s == 'ConductionFiniteDifference'
      hba.setString(0, 'ConductionFiniteDifference')
      runner.registerInfo('HeatBalanceAlgorithm = ConductionFiniteDifference')
    end

    # array to hold new IDF objects
    string_objects1 = []
    
    # Construct the Material IDF object
      string_objects1 << "
 
      Material,
        #{pcm_name},                		      !- Name
        #{pcm_rough},                  		!- Roughness
        #{pcm_thickness},                     	!- Thickness {m}
        #{pcm_cond},                      		!- Conductivity {W/m-K}
        #{pcm_den},                      		!- Density {kg/m3}
        #{pcm_sp_heat},                      	!- Specific Heat {J/kg-K}
        #{pcm_abs},               			!- Thermal Absorptance
        #{pcm_sol_abs},               		!- Solar Absorptance
        #{pcm_vis_abs};               		!- Visible Absorptance
        "

    # add all of the strings to workspace to create IDF objects
    string_objects1.each do |string_object|
      idfObject = OpenStudio::IdfObject::load(string_object)
      object = idfObject.get
      wsObject = workspace.addObject(object)
    end    

    # array to hold new IDF objects
    string_objects2 = []

    # Construct the MaterialProperty:PhaseChange IDF object
    string_objects2 << "

    MaterialProperty:PhaseChange,
        #{pcm_name},                		       !- Name
        #{temp_coeff},                 	!- Temperature coefficient, thermal conductivity (W/m K2)
        #{temp1},                      		!- Temperature 1, C
        #{enthalpy1},                      	       !- Enthalpy 1, (J/kg)
        #{temp2},                      		!- Temperature 2, C
        #{enthalpy2},                      	       !- Enthalpy 2, (J/kg)
        #{temp3},                      		!- Temperature 3, C
        #{enthalpy3},                      	       !- Enthalpy 3, (J/kg)
        #{temp4},                      		!- Temperature 4, C
        #{enthalpy4};                      	       !- Enthalpy 4, (J/kg)

    "
    # add all of the strings to workspace to create IDF objects
    string_objects2.each do |string_object|
      idfObject = OpenStudio::IdfObject::load(string_object)
      object = idfObject.get
      wsObject = workspace.addObject(object)
    end


    # Get all construction objects from the workspace
    constructions = workspace.getObjectsByType("Construction".to_IddObjectType)

    # Iterate over the constructions to find the target constructions
    constructions.each do |construction|
      # === First envelope (check for empty) ===
      if !envelope_name.nil? && !envelope_name.empty? && construction.getString(0).to_s == envelope_name
        layers = []
        (1..construction.numFields - 1).each do |i|
          layer = construction.getString(i).to_s
          layers << layer unless layer.empty?
        end

        # Insert the PCM material at the desired position
        layers.insert(pcm_index, pcm_name)

        # Update the construction object with the modified layers
        layers.each_with_index do |layer, i|
          construction.setString(i + 1, layer)
        end

        # Remove any extra fields left over from the original construction
        ((layers.size + 1)..(construction.numFields - 1)).each do |i|
          construction.setString(i, "") # Clear unused fields
        end

        runner.registerInfo("PCM added to construction of envelope: #{envelope_name}")
      end
    end

    # Check for empty second envelope before starting the loop
    if envelope_name2.nil? || envelope_name2.empty?
      runner.registerInfo("No second envelope selected. Skipping second PCM insertion.")
      envelope_name2 = nil # Ensure envelope_name2 is set to nil if empty
    end
    constructions.each do |construction|
      if envelope_name2 && !envelope_name2.empty? && construction.getString(0).to_s == envelope_name2
        layers = []
        (1..construction.numFields - 1).each do |i|
          layer = construction.getString(i).to_s
          layers << layer unless layer.empty?
        end

        # Insert the PCM material at the desired position
        layers.insert(pcm_index2, pcm_name)

        # Update the construction object with the modified layers
        layers.each_with_index do |layer, i|
          construction.setString(i + 1, layer)
        end

        # Remove any extra fields left over from the original construction
        ((layers.size + 1)..(construction.numFields - 1)).each do |i|
          construction.setString(i, "") # Clear unused fields
        end

        runner.registerInfo("PCM added to second construction of envelope: #{envelope_name2}")
      end
    end

  end
end

# register the measure to be used by the application
AddPCMtoEnv.new.registerWithApplication
