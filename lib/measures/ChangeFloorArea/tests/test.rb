require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb' # Adjust path if necessary

class ChangeFloorArea_Test < Minitest::Test
  def setup
    # Load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(File.expand_path("../model_test.osm", __FILE__)) # Ensure the path is correct
    model = translator.loadModel(path)
    assert(!model.empty?, "Model could not be loaded.")
    @model = model.get
  end

  def test_floor_area
    measure = ChangeFloorArea.new
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)
    arguments = measure.arguments(@model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    puts argument_map.inspect

    # Variable: Floor area to be changed
    argument_map['fa_fraction'].setValue(1)

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
