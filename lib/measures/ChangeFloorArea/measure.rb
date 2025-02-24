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
    return "This measure will change the floor area of a building multiplying by a user-defined fraction."
  end

  def modeler_description
    return "The floor area and associated vertices of the building surfaces will be changed.
            Primarily it is tested for a single zone model"
  end

  # return a vector of arguments
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Fraction of floor area to be increased
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

    # Check all the surfaces and find floor surfaces, then get their vertices
    floor_surface = []
    width = 0
    length = 0
    surfaces.each do |surface|
      runner.registerInfo("Surface Name: #{surface.name}")

      # Check if the surface is a floor
      if surface.surfaceType == "Floor"
        floor_surface << surface
        runner.registerInfo("Vertices for floor surface: #{surface.name}:")

        # Loop through the vertices of the surface
        surface.vertices.each do |vertex|
          runner.registerInfo("  Vertex: (#{vertex.x}, #{vertex.y}, #{vertex.z})")
          
          # Check the vertices to determine width and length
          if vertex.z == 0 && vertex.x == 0 && vertex.y != 0
            width = vertex.y
          elsif vertex.z == 0 && vertex.y == 0 && vertex.x != 0
            length = vertex.x
          end
        end
      end
    end

    # Log the final width and length of the building
    runner.registerInfo("Length of building: #{length}")
    runner.registerInfo("Width of building: #{width}")

    # Aspect ratio of building along east west direction
    ar = length/width
    runner.registerInfo("Aspect ratio (AR): #{ar}")

    # new length after changing floor area
    old_area = length * width 
    new_area = old_area * fa_fraction
    new_width = Math.sqrt(new_area/ar)
    new_length = ar * new_width
    runner.registerInfo("Old and new area are #{old_area} and #{new_area}")
    runner.registerInfo("New width and length are #{new_width} and #{new_length}")

    # Calculate the scaling ratios for length and width
    len_ratio = new_length / length  # Ratio for scaling length
    wid_ratio = new_width / width    # Ratio for scaling width



    # Loop through all surfaces and modify the vertices based on these ratios
    surfaces.each do |surface|      
      # Retrieve the vertices of the surface
      original_vertices = surface.vertices
      
      # Create a new array for the modified vertices
      new_vertices = original_vertices.map do |vertex|
        # Modify the coordinates using the scaling ratios
        new_x = vertex.x * len_ratio  # Scale X by len_ratio
        new_y = vertex.y * wid_ratio  # Scale Y by wid_ratio
        new_z = vertex.z              # Keep Z unchanged (if necessary)
        
        # Create a new Point3d with modified coordinates
        OpenStudio::Point3d.new(new_x, new_y, new_z)
      end

      # Set the new vertices to the surface
      surface.setVertices(new_vertices)

      # Log the new vertices for each surface
      runner.registerInfo("Updated Vertices for surface #{surface.name}:")
      new_vertices.each do |vertex|
        runner.registerInfo("  Vertex: (#{vertex.x}, #{vertex.y}, #{vertex.z})")
      end
    end

    runner.registerInfo("Surface vertices updated in the model with scaling ratios.")

  end
end

# this allows the measure to be used by the application
ChangeFloorArea.new.registerWithApplication
