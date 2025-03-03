# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

# frozen_string_literal: true

class AddSolarPVT < OpenStudio::Measure::ModelMeasure

  def name
    return "AddSolarPVT"
  end
  def description
    return "This measure will add solar PhotoVoltaicThermal object to the system. PVT system can be add to airloop outdoor air system or plant loop"
  end
  def modeler_description
    return "Solar PhotoVoltaicThermal object generate electricity and supply thermal energy. In order use thermal energy to heat water,
    a Plant Loop must be created. The emply plant loop will contain a Pump to the supply inlet node, SetpointManagerSchedule object to supply outlet node
    and a water heating object to supply outlet. This Measure will create a Secondry Plant Loop that will contain a PV Collector to supply inlet, then a Pump,
    then a Storage Tank and the same SetpointManagerSchedule.
    The Storage Tank to secondary loop will be added to demand side of Primary Plant Loop"
  end
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    ## SolarCollector:FlatPlate:PhotovoltaicThermal

    # Name of the object
    obj_name = OpenStudio::Measure::OSArgument.makeStringArgument('obj_name', true)
    obj_name.setDisplayName('Name for the PVT object')
    obj_name.setDefaultValue('Solar PhotoVoltaic Thermal Obj')
    args << obj_name
    
    # Surface name (dynamic choice argument)
    surfaces = model.getSurfaces
    surf_names = OpenStudio::StringVector.new
    surfaces.each do |surface|
      surf_names << surface.nameString
    end

    surf_name = OpenStudio::Measure::OSArgument.makeChoiceArgument('surf_name', surf_names, true)
    surf_name.setDisplayName('Surface Name')
    surf_name.setDefaultValue(surf_names[1])  # Set the first surface name as the default value
    args << surf_name

    # Working fluid type
    chs = OpenStudio::StringVector.new
    chs << "Water"
    chs << "Air"
    work_fluid = OpenStudio::Measure::OSArgument::makeChoiceArgument('work_fluid', chs, true)
    work_fluid.setDefaultValue("Air")
    work_fluid.setDisplayName('Working fluid type (Air or Water)')
    args << work_fluid

    # Name of the Plant Loop 
    plant_loop_name = OpenStudio::Measure::OSArgument.makeStringArgument('plant_loop_name', true)
    plant_loop_name.setDisplayName('Existing Plant Loop Name')
    plant_loop_name.setDefaultValue("HTR WTR Loop")
    args << plant_loop_name

    # Name of the AirLoop HVAC Outdoor Air
    air_loop_name = OpenStudio::Measure::OSArgument.makeStringArgument('air_loop_name', true)
    air_loop_name.setDisplayName('Existing AirLoop HVAC Outdoor Air Name')
    air_loop_name.setDefaultValue("Outdoor Air System")
    args << air_loop_name
    
    # Design flow rate
    design_flow_rate = OpenStudio::Measure::OSArgument.makeDoubleArgument('design_flow_rate', true)
    design_flow_rate.setDisplayName('Design flow rate (m3/s)')
    design_flow_rate.setDefaultValue(0.00004)
    args << design_flow_rate

    # Node to add Storage Tank to Primary Plant Loop  
    node_storage_tank = OpenStudio::Measure::OSArgument.makeStringArgument('node_storage_tank', true)
    node_storage_tank.setDisplayName('Node to add Storage Tank to Primary Plant Loop')
    node_storage_tank.setDefaultValue("Node 1")
    args << node_storage_tank

    ## SolarCollectorPerformance:PhotovoltaicThermal:Simple

    # Name of the SolarCollectorPerformance object
    per_name = OpenStudio::Measure::OSArgument.makeStringArgument('per_name', true)
    per_name.setDisplayName('SolarCollectorPerformance:PhotovoltaicThermal Name')
    per_name.setDefaultValue("Performance Obj")
    args << per_name

    # set fraction_of_surface
    fract_of_surface = OpenStudio::Measure::OSArgument.makeDoubleArgument('fract_of_surface', true)
    fract_of_surface.setDisplayName('Fraction of Surface Area with Active Thermal Collector')
    fract_of_surface.setUnits('fraction')
    fract_of_surface.setDefaultValue(0.75)
    args << fract_of_surface

    # set thermal conversion efficiency
    chs = OpenStudio::StringVector.new
    chs << "Fixed"
    chs << "Scheduled"
    therm_eff = OpenStudio::Measure::OSArgument::makeChoiceArgument('therm_eff', chs, true)
    therm_eff.setDefaultValue("Fixed")
    therm_eff.setDisplayName('Thermal Conversion Eﬀiciency Input Mode (Currently only Fixed)')
    args << therm_eff

    # Value for Thermal Conversion Eﬀiciency if Fixed
    ther_eff_val = OpenStudio::Measure::OSArgument.makeDoubleArgument('ther_eff_val', false)
    ther_eff_val.setDisplayName('Thermal Conversion Eﬀiciency')
    ther_eff_val.setUnits('fraction')
    ther_eff_val.setDefaultValue(0.20)
    args << ther_eff_val

    # # Name of Schedule for Thermal Conversion Eﬀiciency
    # schedules = model.getSchedules
    # schedule_names = OpenStudio::StringVector.new
    # schedules.each do |schedule|
    #   schedule_names << schedule.nameString
    # end

    # schedule_name = OpenStudio::Measure::OSArgument.makeChoiceArgument('schedule_name', schedule_names, false)
    # schedule_name.setDisplayName('Schedule Name for Thermal Conversion Eﬀiciency')
    # args << schedule_name

    # Front Surface Emittance
    front_surf_emittance = OpenStudio::Measure::OSArgument.makeDoubleArgument('front_surf_emittance', true)
    front_surf_emittance.setDisplayName('Front Surface Emittance')
    front_surf_emittance.setUnits('fraction')
    front_surf_emittance.setDefaultValue(0.90)
    args << front_surf_emittance


    ## Generator:Photovoltaic
    # Photovoltaic Generator Name
    generator_name = OpenStudio::Measure::OSArgument.makeStringArgument('generator_name', true)
    generator_name.setDisplayName('Generator:Photovoltaic Name')
    generator_name.setDefaultValue('Generator Obj')
    args << generator_name

    
    ## PhotovoltaicPerformance:Simple

    # Fraction of surfaces to contain PV
    frac_surf_area_with_pv = OpenStudio::Measure::OSArgument.makeDoubleArgument('frac_surf_area_with_pv', true)
    frac_surf_area_with_pv.setDisplayName('Fraction of Included Surface Area with PV')
    frac_surf_area_with_pv.setDefaultValue(0.75)
    args << frac_surf_area_with_pv

    # #Conversion Eﬀiciency Input Mode
    chs1 = OpenStudio::StringVector.new
    chs1 << "Fixed"
    chs1 << "Scheduled"
    conversion_eff = OpenStudio::Measure::OSArgument::makeChoiceArgument('conversion_eff', chs1, true)
    conversion_eff.setDisplayName('Thermal Conversion Eﬀiciency Input Mode (currently Fixed only)')
    conversion_eff.setDefaultValue("Fixed")
    args << conversion_eff

    # Value for Conversion Conversion Eﬀiciency if Fixed
    conversion_eff_val = OpenStudio::Measure::OSArgument.makeDoubleArgument('conversion_eff_val', false)
    conversion_eff_val.setDisplayName('Generator Conversion Eﬀiciency NB: Total efficiency of thermal and PV must be <=1')
    conversion_eff_val.setUnits('fraction')
    conversion_eff_val.setDefaultValue(0.3)
    args << conversion_eff_val

    # # Name of Schedule for Conversion Eﬀiciency
    # pv_schedule_name = OpenStudio::Measure::OSArgument.makeChoiceArgument('pv_schedule_name', schedule_names, false)
    # pv_schedule_name.setDisplayName('PV Schedule Name')
    # args << pv_schedule_name

    # Storage Tank Volume
    storage_vol = OpenStudio::Measure::OSArgument.makeDoubleArgument('storage_vol', true)
    storage_vol.setDisplayName('Storage Tank Volume (m3)')
    storage_vol.setDefaultValue(0.19)
    args << storage_vol

    return args
  end



  def run(model, runner, user_arguments)
    super(model, runner, user_arguments) # Do **NOT** remove this line

    # Use the built-in error checking
    unless runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # Retrieve arguments
    obj_name = runner.getStringArgumentValue('obj_name', user_arguments)
    surf_name = runner.getStringArgumentValue('surf_name', user_arguments)
    work_fluid = runner.getStringArgumentValue('work_fluid', user_arguments)
    wf_design_flowrate = runner.getDoubleArgumentValue('design_flow_rate', user_arguments)
    node_storage_tank = runner.getStringArgumentValue('node_storage_tank', user_arguments)
    per_name = runner.getStringArgumentValue('per_name', user_arguments)
    fract_of_surface = runner.getDoubleArgumentValue('fract_of_surface', user_arguments)
    therm_eff = runner.getStringArgumentValue('therm_eff', user_arguments)
    ther_eff_val = runner.getDoubleArgumentValue('ther_eff_val', user_arguments)
    # schedule_name = runner.getStringArgumentValue('schedule_name', user_arguments)
    front_surf_emittance = runner.getDoubleArgumentValue('front_surf_emittance', user_arguments)
    generator_name = runner.getStringArgumentValue('generator_name', user_arguments)
    frac_surf_area_with_pv = runner.getDoubleArgumentValue('frac_surf_area_with_pv', user_arguments)
    conversion_eff = runner.getStringArgumentValue('conversion_eff', user_arguments)
    conversion_eff_val = runner.getDoubleArgumentValue('conversion_eff_val', user_arguments)
    # pv_schedule_name = runner.getStringArgumentValue('pv_schedule_name', user_arguments)
    storage_vol = runner.getDoubleArgumentValue('storage_vol', user_arguments)
    plant_loop_name = runner.getStringArgumentValue('plant_loop_name', user_arguments)
    air_loop_name = runner.getStringArgumentValue('air_loop_name', user_arguments)


    # Validate selected surface
    pvt_surfaces = model.getSurfaceByName(surf_name)
    if pvt_surfaces.empty?
      runner.registerError("The selected surface '#{surf_name}' was not found in the model.")
      return false
    end
    pvt_surface = pvt_surfaces.get

    # PlantLoop nodes
    plant_loops = model.getPlantLoopByName(plant_loop_name.chomp)
    if not plant_loops.empty?
      plant_loop = plant_loops.get
    end
    runner.registerInfo("The Plant Loop object is #{plant_loop.nameString}")

    # Airloop Outdoor Air nodes
    oa_loops = model.getAirLoopHVACOutdoorAirSystemByName(air_loop_name.chomp)
    if not oa_loops.empty?
      oa_loop = oa_loops.get
      outdoorAirNodes = oa_loop.outboardOANode

      if not outdoorAirNodes.empty?
        outdoorAirNode = outdoorAirNodes.get
      end

    end
    runner.registerInfo("The outdoor air supply node is #{outdoorAirNode.nameString}")
    # Placeholder for creating a PVT object
    runner.registerInfo("Creating a PVT object named '#{obj_name}' on surface '#{surf_name}'.")
    # Placeholder for creating a PVT object
    runner.registerInfo("Creating a PV Generator object named '#{generator_name}' on surface '#{surf_name}'.")
    # Register initial and final condition
    runner.registerInitialCondition("A PVT object named '#{obj_name}'.")

    ## Creating PVT object
    #https://openstudio-sdk-documentation.s3.amazonaws.com/cpp/OpenStudio-1.11.0-doc/utilities_idd/html/classopenstudio_1_1_solar_collector___flat_plate___photovoltaic_thermal_fields.html

    # Adding the PVT collector 
    pv_collector = OpenStudio::Model::SolarCollectorFlatPlatePhotovoltaicThermal.new(model)
    # plant_loop.addSupplyBranchForComponent(pv_collector)
    pv_collector.setName(obj_name)
    pv_collector.setSurface(pvt_surface)

    # Condition whether Air or Water system should be added
    if work_fluid == "Air"
      pv_collector.addToNode(outdoorAirNode)
      runner.registerInfo("PV Collector added to Outdoor Airloop Ventilation")
    else
      # Find the pump object
      water_pump = nil
      cloned_water_pump = ""
      plant_loop.supplyComponents.each do |component|
        if component.to_PumpVariableSpeed.is_initialized
          water_pump = component.to_PumpVariableSpeed.get
          runner.registerInfo("Pump retrieved: #{water_pump.nameString}")

          # Clone the water heater so that it can be re-added
          cloned_water_pump = water_pump.clone(model).to_PumpVariableSpeed.get
          runner.registerInfo("Cloned water pump: #{cloned_water_pump.name}")
          break
        elsif component.to_PumpConstantSpeed.is_initialized
          water_pump = component.to_PumpConstantSpeed.get
          runner.registerInfo("Pump retrieved: #{water_pump.nameString}")

          # Clone the water heater so that it can be re-added
          cloned_water_pump = water_pump.clone(model).to_PumpConstantSpeed.get
          runner.registerInfo("Cloned water pump: #{cloned_water_pump.name}")
          break
        end
      end

      if water_pump.nil?
        runner.registerError("No pump object found in the plant loop.")
        return false
      end

      # Secondary plant loop
      new_plant_loop = OpenStudio::Model::PlantLoop.new(model)
      new_plant_loop.setName('Secondary Plant Loop')

      # Add the PV collector to the Secondary plant loop
      pv_collector.addToNode(new_plant_loop.supplyInletNode)
      runner.registerInfo("#{pv_collector.nameString} added to Plant Loop Storage at #{new_plant_loop.nameString}")

      # Add the pump to outlet node of collector
      pv_collector_outlet_node = pv_collector.outletModelObject.get.to_Node.get
      cloned_water_pump.addToNode(new_plant_loop.supplyInletNode)


      # Adding a new storage connected to plantloop
      storage_water_heater = OpenStudio::Model::WaterHeaterMixed.new(model)
      storage_water_heater.setName('Storage Hot Water Tank')
      storage_water_heater.setTankVolume(storage_vol)
      storage_water_heater.setHeaterMaximumCapacity(0.0)

      # Add setpoint manager
      storage_setpoint_managers = model.getSetpointManagerScheduledByName("Service hot water setpoint manager")
      if storage_setpoint_managers.empty?
        runner.registerError("SetpointManagerScheduled not found")
        return false
      else
        storage_setpoint_manager = storage_setpoint_managers.get
        runner.registerInfo("Setpoint manager for Plant Loop control #{storage_setpoint_manager.nameString}.")
      end
      # Clone the setpoint manager to add Secondary plant loop
      cloned_setpoint_manager = storage_setpoint_manager.clone(model).to_SetpointManagerScheduled.get
      cloned_setpoint_manager.addToNode(new_plant_loop.supplyOutletNode)
      runner.registerInfo("Service hot water setpoint manager added to the supply outlet node of #{new_plant_loop.nameString}.")

      # Add storage water to demand side of Secondary plant loop
      new_plant_loop.addDemandBranchForComponent(storage_water_heater)
      runner.registerInfo("#{storage_water_heater.nameString} added to the demand side of Secondary plant loop.")

      # Add storage water to existing supply side node of plant loop (primary)
      node_storage_tank = model.getNodeByName("Node 1").get
      storage_water_heater.addToNode(node_storage_tank)
      runner.registerInfo("#{storage_water_heater.nameString} added to node #{node_storage_tank.nameString}.")
    end

    # create the pv_generator
    pv_generator = OpenStudio::Model::GeneratorPhotovoltaic.simple(model)
    pv_generator.setSurface(pvt_surface)
    # create the inverter
    inverter = OpenStudio::Model::ElectricLoadCenterInverterSimple.new(model)
    # create the distribution system
    elcd = OpenStudio::Model::ElectricLoadCenterDistribution.new(model)
    elcd.addGenerator(pv_generator)
    elcd.setInverter(inverter)
    # Assign the PV Generator to the collector
    pv_collector.setGeneratorPhotovoltaic(pv_generator)
    pv_collector.autosizeDesignFlowRate


    pv_collector_performance = pv_collector.solarCollectorPerformance.to_SolarCollectorPerformancePhotovoltaicThermalSimple.get
    pv_collector_performance.setName(per_name)
    pv_collector_performance.setFractionOfSurfaceAreaWithActiveThermalCollector(fract_of_surface)
    # pv_collector_performance.setThermalConversionEﬀiciencyInputMode(therm_eff)
    pv_collector_performance.setThermalConversionEfficiency(ther_eff_val)
    pv_collector_performance.setFrontSurfaceEmittance(front_surf_emittance)

    runner.registerFinalCondition("PVT object named '#{obj_name}' successfully added to surface '#{surf_name}'.")

    ## Set output variables 
    outputVariablePVT = false
    if outputVariablePVT
      collector.outputVariableNames.each do |var|
        OpenStudio::Model::OutputVariable.new(var, model)
      end
    end

    return true
  end
end

# Register the measure to be used by the application
AddSolarPVT.new.registerWithApplication