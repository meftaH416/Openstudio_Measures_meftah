

###### (Automatically generated documentation)

# AddPVT

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


___
## Table of Contents
- [Measure Overview](#measure-overview)<br/>
- [Other Examples](#other-examples)<br/>
- [Automatically Generated Argument List](#arguments)<br/>

## Measure Overview

The intent of this measure is to give the user the ability to shift schedules, thereby giving some control over the timing of energy use.
A daily peak period is defined using a start and end hour of the day.
This represents a peak demand window for which customers, e.g., might be penalized for running home appliances.
Schedule values falling within the peak period are then shifted back in time, to start at the end of the peak period.
An optional delay value can be specified to control how many hours after the peak period final hour the load shift should begin.
By default, only schedule values occuring during weekdays can be shifted.
However, an optional argument can be supplied to additionally enable schedule shifts for weekend days.
Users also have the ability to disallow overlapping of shifted schedules onto any existing events.
By default, however, schedules are shifted to periods that already have non-zero schedule values.
In terms of specifying which schedules may be shifted, the user may provide comma-separated lists of schedule names for both ScheduleRuleset and ScheduleFile object types.
Any schedule whose name is not listed is not available to receive any schedule shifts.

The following illustrates a simple shift that has been applied to a refrigerator schedule.
The first 5 weekdays of the year show the appliance load shifted back to start at the end of the peak period.
The peak period does not apply to weekends, and so the final 2 weekend days does not show any shifted schedules.

![Overview](./docs/measures-overview.png?raw=true)

It's important to note that although this measure has been written generically to support any schedules of either the ScheduleRuleset of ScheduleFile type, it has only been tested in the context of residential workflows (i.e, ResStock).
Users applying this measure in other (untested) workflows should use caution.

## Other Examples

Below are additional examples illustrating various scenarios for changing values supplied to measure arguments.

### Shorter peak period

*Peak Period*: 5pm - 7pm |
*Delay*: None |
*Weekdays Only*: Yes

![Shorter Peak Period](./docs/other-examples1.png?raw=true)

### Non-zero delay value

*Peak Period*: 3pm - 7pm |
*Delay*: 1hr |
*Weekdays Only*: Yes

![Nonzero Delay Value](./docs/other-examples2.png?raw=true)

### Applied to weekends

*Peak Period*: 3pm - 7pm |
*Delay*: None |
*Weekdays Only*: No

![Applied To Weekends](./docs/other-examples3.png?raw=true)

___

*(Automatically generated argument information follows)*

## Arguments


### Uniquie Name for the PVT object

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


### Thermal Conversion Eﬀiciency Input Mode Type

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


### Schedule Name for Thermal Conversion Eﬀiciency

**Name:** schedule_name,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

**Choice Display Names** []


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


### Thermal Conversion Eﬀiciency Input Mode Type

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


### PV Schedule Name

**Name:** pv_schedule_name,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

**Choice Display Names** []


### Storage Tank Volume (m3)

**Name:** storage_vol,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false






