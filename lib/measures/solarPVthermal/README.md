

###### (Automatically generated documentation)

# AddSolarPVT

## Description
This measure will add solar PhotoVoltaicThermal object to the system. PVT system can be add to airloop outdoor air system or plant loop

## Modeler Description
Solar PhotoVoltaicThermal object generate electricity and supply thermal energy. In order use thermal energy to heat water,
    a Plant Loop must be created. The emply plant loop will contain a Pump to the supply inlet node, SetpointManagerSchedule object to supply outlet node
    and a water heating object to supply outlet. This Measure will create a Secondry Plant Loop that will contain a PV Collector to supply inlet, then a Pump,
    then a Storage Tank and the same SetpointManagerSchedule.
    The Storage Tank to secondary loop will be added to demand side of Primary Plant Loop

## Measure Type
ModelMeasure

## Taxonomy

Incase that user want to use this PVT object for water heating, they need to create a primary plant loop including Pump to supply inlet node, WaterHeaterMixed and a SetPointManagerSchedule added to supply outlet node. Please see the PNG file named plantloop for visualization. The primary file will have everything except the middle WaterStorage (it has double connection in the image).

The measure will create a PVT collector similar to the PNG file named solarloop.  Look that the WaterStorage is on the demand side of the secondary loop. 

This WaterStorage object will be added to user defined Node of primary loop as shown in plantloop PNG file. 

## Arguments


### Name for the PVT object

**Name:** obj_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Surface Name

**Name:** surf_name,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** []


### Working fluid type (Air or Water)

**Name:** work_fluid,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** ["Water", "Air"]


### Existing Plant Loop Name

**Name:** plant_loop_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Existing AirLoop HVAC Outdoor Air Name

**Name:** air_loop_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Design flow rate (m3/s)

**Name:** design_flow_rate,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Node to add Storage Tank to Primary Plant Loop

**Name:** node_storage_tank,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### SolarCollectorPerformance:PhotovoltaicThermal Name

**Name:** per_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Fraction of Surface Area with Active Thermal Collector

**Name:** fract_of_surface,
**Type:** Double,
**Units:** fraction,
**Required:** true,
**Model Dependent:** false


### Thermal Conversion Eﬀiciency Input Mode (Currently only Fixed)

**Name:** therm_eff,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** ["Fixed", "Scheduled"]


### Thermal Conversion Eﬀiciency

**Name:** ther_eff_val,
**Type:** Double,
**Units:** fraction,
**Required:** false,
**Model Dependent:** false


### Front Surface Emittance

**Name:** front_surf_emittance,
**Type:** Double,
**Units:** fraction,
**Required:** true,
**Model Dependent:** false


### Generator:Photovoltaic Name

**Name:** generator_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Fraction of Included Surface Area with PV

**Name:** frac_surf_area_with_pv,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Thermal Conversion Eﬀiciency Input Mode (currently Fixed only)

**Name:** conversion_eff,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** ["Fixed", "Scheduled"]


### Generator Conversion Eﬀiciency NB: Total efficiency of thermal and PV must be <=1

**Name:** conversion_eff_val,
**Type:** Double,
**Units:** fraction,
**Required:** false,
**Model Dependent:** false


### Storage Tank Volume (m3)

**Name:** storage_vol,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false






