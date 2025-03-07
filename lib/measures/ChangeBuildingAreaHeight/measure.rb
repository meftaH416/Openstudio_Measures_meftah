# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# *******************************************************************************

class ChangeBuildingSize < OpenStudio::Measure::ModelMeasure

  def name
    return "Change Building Size"
  end

  def description
    return "This measure will change the building area (footprint) and height of a building multiplying by user-defined fractions."
  end

  def modeler_description
    return "The floor area, roof area, and associated vertices of the building surfaces, as well as the building height, will be changed."
  end

  # return a vector of arguments
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Fraction of floor area to be increased
    fa_fraction = OpenStudio::Measure::OSArgument.makeDoubleArgument("fa_fraction", true)
    fa_fraction.setDisplayName('Fractional increase (or decrease) in floor area')
    fa_fraction.setDefaultValue(1.0)
    args << fa_fraction

    # Fraction of building height to be increased
    height_fraction = OpenStudio::Measure::OSArgument.makeDoubleArgument("height_fraction", true)
    height_fraction.setDisplayName('Fractional increase (or decrease) in building height')
    height_fraction.setDefaultValue(1.0)
    args << height_fraction

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
    height_fraction = runner.getDoubleArgumentValue("height_fraction", user_arguments)

    # Get all surfaces
    surfaces = model.getSurfaces

    runner.registerInfo("Number of surfaces: #{surfaces.size}")

    # Function to calculate the enclosed area of a polygon using Shoelace Theorem
    def calculate_polygon_area(vertices)
      n = vertices.length
      area = 0.0

      (0...n).each do |i|
        x1, y1 = vertices[i]
        x2, y2 = vertices[(i + 1) % n]
        area += (x1 * y2) - (y1 * x2)
      end

      return (area.abs / 2.0)
    end

    # Function to calculate the length of each side of the polygon
    def calculate_side_lengths(vertices)
      n = vertices.length
      side_lengths = []

      (0...n).each do |i|
        x1, y1 = vertices[i]
        x2, y2 = vertices[(i + 1) % n]
        length = Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
        side_lengths << length
      end

      return side_lengths
    end

    # Function to find the centroid of a polygon
    def calculate_centroid(vertices)
      x_sum = 0.0
      y_sum = 0.0
      n = vertices.length

      vertices.each do |v|
        x_sum += v[0]
        y_sum += v[1]
      end

      return [x_sum / n, y_sum / n]
    end

    total_old_area = 0.0
    total_old_height = 0.0
    floor_and_roof_surfaces = []

    # Track old and new height values
    old_height = 0.0
    new_height = 0.0

    surfaces.each do |surface|
      if surface.surfaceType == "Floor" || surface.surfaceType == "RoofCeiling"
        floor_and_roof_surfaces << surface

        vertices = surface.vertices.select { |v| v.z == 0 }.map { |v| [v.x, v.y] }

        if vertices.length < 3
          runner.registerInfo("Skipping #{surface.name}: Not enough vertices to form a polygon.")
          next
        end

        floor_area = calculate_polygon_area(vertices)
        total_old_area += floor_area

        side_lengths = calculate_side_lengths(vertices)
        runner.registerInfo("#{surface.surfaceType} #{surface.name}: Area = #{floor_area} m², Side lengths = #{side_lengths.join(', ')} m")
      end
    end

    # Scaling factor for each side length (floor area)
    len_wid_frac = Math.sqrt(fa_fraction)
    runner.registerInfo("Scaling factor for sides: #{len_wid_frac}")

    # Apply the scaling to all floor and roof surfaces
    surfaces.each do |surface|
      original_vertices = surface.vertices
      runner.registerInfo("Old vertices for #{surface.name}:")
      original_vertices.each { |v| runner.registerInfo("  (#{v.x}, #{v.y}, #{v.z})") }

      # Compute the centroid of the original polygon (x, y only)
      vertices_2d = original_vertices.map { |v| [v.x, v.y] }
      centroid = calculate_centroid(vertices_2d)

      # Scale vertices relative to the centroid
      new_vertices = original_vertices.map do |vertex|
        new_x = centroid[0] + (vertex.x - centroid[0]) * len_wid_frac
        new_y = centroid[1] + (vertex.y - centroid[1]) * len_wid_frac
        OpenStudio::Point3d.new(new_x, new_y, vertex.z) # Keep Z unchanged
      end

      surface.setVertices(new_vertices)

      runner.registerInfo("Updated vertices for #{surface.name}:")
      new_vertices.each { |v| runner.registerInfo("  (#{v.x}, #{v.y}, #{v.z})") }
    end

    ## Recalculating new floor and roof area. This checks the accuracy of the measure
    total_new_area = 0.0
    surfaces.each do |surface|
      if surface.surfaceType == "Floor" || surface.surfaceType == "RoofCeiling"
        vertices = surface.vertices.select { |v| v.z == 0 }.map { |v| [v.x, v.y] }

        if vertices.length < 3
          runner.registerInfo("Skipping #{surface.name}: Not enough vertices to form a polygon.")
          next
        end

        new_floor_area = calculate_polygon_area(vertices)
        total_new_area += new_floor_area

        side_lengths = calculate_side_lengths(vertices)
        runner.registerInfo("New #{surface.surfaceType} #{surface.name}: Area = #{new_floor_area} m², Side lengths = #{side_lengths.join(', ')} m")
      end
    end

    # Apply height scaling to vertical surfaces (walls, windows, doors) and the roof
    surfaces.each do |surface|
      next if surface.surfaceType == "Floor" || surface.surfaceType == "RoofCeiling" # Skip floor and roof surfaces for height scaling

      runner.registerInfo("Scaling height of surface: #{surface.name}")

      original_vertices = surface.vertices
      new_vertices = original_vertices.map do |vertex|
        # Scale the Z-coordinate to apply height fraction
        new_z = vertex.z * height_fraction
        OpenStudio::Point3d.new(vertex.x, vertex.y, new_z)
      end

      surface.setVertices(new_vertices)
      runner.registerInfo("Updated height for #{surface.name}:")
      new_vertices.each { |v| runner.registerInfo("  (#{v.x}, #{v.y}, #{v.z})") }
    end

    # Calculate and show the old and new building height (max Z-value for vertical surfaces)
    old_height = surfaces.select { |s| s.surfaceType == "Wall" || s.surfaceType == "RoofCeiling" }.map { |s| s.vertices.map(&:z).max }.max
    new_height = old_height * height_fraction

    runner.registerInfo("Old building height: #{old_height} m")
    runner.registerInfo("New building height: #{new_height} m")

    runner.registerInfo("Old total area: #{total_old_area} m²")
    runner.registerInfo("New total area: #{total_new_area} m² (Scaling factor for area: #{fa_fraction})")
    return true
  end
end

# this allows the measure to be used by the application
ChangeBuildingSize.new.registerWithApplication
