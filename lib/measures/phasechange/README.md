

###### (Automatically generated documentation)

# AddPCMtoEnv

## Description
This measure can create new material with phase change property from user inputs and edit the idf file to run simulation.

## Modeler Description
This measure will replace heatbalance algorithm to CondFD, add new materials with phase change property and add the PCM material to a specific layer of any construction. 

## Measure Type
EnergyPlusMeasure

## Taxonomy


## Arguments


### Time step in an hour (Value should be equal or greater than 20)

**Name:** time_step,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Choose Construction where PCM is intended to add

**Name:** envelope_name,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### 1st PCM Layer Position

**Name:** pcm_index,
**Type:** Integer,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### (Optional): Choose another Construction where PCM is intended to add

**Name:** envelope_name2,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### 2nd PCM Layer Position

**Name:** pcm_index2,
**Type:** Integer,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### PCM Layer Name

**Name:** pcm_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### PCM Layer Thickness (m)

**Name:** pcm_thickness,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### PCM Conductivity (W/m-k)

**Name:** pcm_cond,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### PCM Density (kg/m3)

**Name:** pcm_den,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### PCM Specific Heat (J/kg-k)

**Name:** pcm_sp_heat,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Roughness

**Name:** pcm_rough,
**Type:** String,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### PCM Thermal Absorptance

**Name:** pcm_abs,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### PCM Solar Absorptance

**Name:** pcm_sol_abs,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### PCM Visible Absorptance

**Name:** pcm_vis_abs,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Temperature coefficient

**Name:** temp_coeff,
**Type:** Double,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Temperature 1 (°C)

**Name:** temp1,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Enthalpy 1 (J/kg)

**Name:** enthalpy1,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Temperature 2 (°C)

**Name:** temp2,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Enthalpy 2 (J/kg)

**Name:** enthalpy2,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Temperature 3 (°C)

**Name:** temp3,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Enthalpy 3 (J/kg)

**Name:** enthalpy3,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Temperature 4 (°C)

**Name:** temp4,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Enthalpy 4 (J/kg)

**Name:** enthalpy4,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false




