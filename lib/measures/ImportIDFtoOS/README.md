

###### (Automatically generated documentation)

# Import IDF to OS

## Description
This measure allows you to import an IDF file to Openstudio without further process. It is created on top of Inject IDF Object measure by NREL.

## Modeler Description
This measure allows the user to import an IDF file to Openstudio without editing. User may require to import weather file only.
    Openstudio can not import HVAC and other objects. This measure will make sure that all IDF objects are imported

## Measure Type
EnergyPlusMeasure

## Taxonomy


## Arguments


### IDF File Name
The idf file to be imported
**Name:** source_idf_path,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false




