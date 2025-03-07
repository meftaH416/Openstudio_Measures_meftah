require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb' # Adjust path if necessary

class ChangeBuildingSize_Test < Minitest::Test
  def setup
    # Load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.expand_path("../model_test.osm", __FILE__)) # Ensure the path is correct
    model = translator.loadModel(path)
    assert(!model.empty?, "Model could not be loaded.")
    @model = model.get
  end

  def test_floor_area_and_height
    measure = ChangeBuildingSize.new
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)
    arguments = measure.arguments(@model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # Variable: Fraction to change floor area and height
    fa_fraction = 1.1  # Example: 10% increase in floor area
    height_fraction = 1.05  # Example: 5% increase in building height
    argument_map['fa_fraction'].setValue(fa_fraction)
    argument_map['height_fraction'].setValue(height_fraction)

    # Run the measure
    measure.run(@model, runner, argument_map)
    result = runner.result

    # Show output messages
    show_output(result)

    # Assertions
    assert_equal("Success", result.value.valueName, "Measure did not complete successfully.")
    assert(result.info.size > 0, "Expected at least one info message.")
    assert(result.warnings.size == 0, "Expected no warnings.")

    # Check that floor area has been updated
    floor_surfaces = @model.getSurfaces.select { |surface| surface.surfaceType == "Floor" }
    floor_surfaces.each do |surface|
      # Get the old and new area for the surface and verify scaling
      old_area = surface.grossArea
      new_area = old_area * fa_fraction

      assert_in_delta(new_area, surface.grossArea, 0.1, "Area was not scaled correctly for surface #{surface.name}.")
    end

    # Check that height has been updated
    # Get the old and new height for the building surfaces (walls and roof)
    old_height = @model.getSurfaces.select { |s| s.surfaceType == "Wall" || s.surfaceType == "RoofCeiling" }.map { |s| s.vertices.map(&:z).max }.max
    new_height = old_height * height_fraction

    @model.getSurfaces.each do |surface|
      next if surface.surfaceType == "Floor" || surface.surfaceType == "RoofCeiling" # Skip floor and roof surfaces for height scaling

      surface_height = surface.vertices.map(&:z).max
      assert_in_delta(new_height, surface_height, 0.1, "Height was not scaled correctly for surface #{surface.name}.")
    end
  end
end
