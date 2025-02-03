require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb' # Adjust path if necessary

class AddSolarPVT_Test < Minitest::Test
  def setup
    # Load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.expand_path("../modelPVT.osm", __FILE__)) # Ensure the path is correct
    model = translator.loadModel(path)
    assert(!model.empty?, "Model could not be loaded.")
    @model = model.get
  end

  def test_add_solar_pvt
    measure = AddSolarPVT.new
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)
    arguments = measure.arguments(@model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)


    puts argument_map.inspect

    # Ensure surf_name is a Choice argument
    surf_name_arg = argument_map['surf_name']
    if surf_name_arg
      # Get the list of available surfaces from the model
      available_surfaces = @model.getSurfaces.map { |s| s.nameString }

      # Check if there are at least two surfaces
      if available_surfaces.size >= 2
        # Set the second surface as the value
        second_surface_name = available_surfaces[1]
        surf_name_arg.setValue(second_surface_name)
      else
        raise "At least two surfaces are required in the model!"
      end
    else
      raise "Argument 'surf_name' not found in the argument map!"
    end

    # Ensure the argument map is updated with the new value
    argument_map['surf_name'] = surf_name_arg


    # Set test arguments
    argument_map['obj_name'].setValue("Test PVT System")
    # argument_map['surf_name'].setValue(surface_name)
    argument_map['work_fluid'].setValue("Water")
    argument_map['plant_loop_name'].setValue("HTR WTR Loop")
    argument_map['air_loop_name'].setValue("Outdoor Air System")
    argument_map['design_flow_rate'].setValue(0.00004)
    argument_map['node_storage_tank'].setValue("Node 1")
    argument_map['per_name'].setValue("Test Performance Obj")
    argument_map['fract_of_surface'].setValue(0.75)
    argument_map['therm_eff'].setValue("Fixed")
    argument_map['ther_eff_val'].setValue(0.20)
    argument_map['front_surf_emittance'].setValue(0.90)
    argument_map['generator_name'].setValue("Test Generator")
    argument_map['frac_surf_area_with_pv'].setValue(0.75)
    argument_map['conversion_eff'].setValue("Fixed")
    argument_map['conversion_eff_val'].setValue(0.3)
    argument_map['storage_vol'].setValue(0.19)

    # Run the measure
    measure.run(@model, runner, argument_map)
    result = runner.result

    # Show output messages
    show_output(result)

    # Assertions
    assert_equal("Success", result.value.valueName, "Measure did not complete successfully.")
    assert(result.info.size > 0, "Expected at least one info message.")
    assert(result.warnings.size == 0, "Expected no warnings.")
  end
end
