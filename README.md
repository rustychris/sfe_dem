# SF Estuary DEM

This repository is a recipe for combining various bathymetry sources
around San Francisco Estuary into seamless digital elevation models.

The shapefile `dem_sources.shp` is the primary description of how
the sources are chosen and blended.  The actual rendering of a DEM for
an area is handled by `stompy.spatial.generate_dem`, which is a module
in the `stompy` repository.

The utility of the specifics in `dem_sources.shp` may be limited to
a small set of users since it relies on having copies of various 
source datasets.  Nonetheless, this repository serves to document
the process and provide a starting point for future modifications.

## Rendering

An example of rendering tiles for a small part of Suisun Marsh:

```
python -m stompy.spatial.generate_dem -s dem_sources.shp -o dem-fm-20190419 
  -p ~/data/bathy_dwr/gtiff
  -p ~/mirrors/ucd-X/Arc_Hydro/CSC_Project/MODELING/1_Hydro_Model_Files/Geometry/Bathymetry_Tiles/NDelta_hydro_2m_v4 
  -p /opt/mirrors/ucd-X/Arc_Hydro/Suisun_CMP/DEMS/Source 
  -b 583000 589000 4226000 4230000 -vv -r 2.0
```   

Breaking that down:
  - `python -m stompy.spatial.generate_dem`: Tell python to invoke the module stompy.spatial.generate_dem.
    This requires that stompy is locatable on your PYTHONPATH or in the current directory.
  - `-s dem_sources.shp`: specify the shapefile that describes which/where source datasets are used.
  - `-o dem-fm-20190419`: directory to save tiles and merged DEM into.  It will be created if it does not exist.
  - `-p ~/data/bathy_dwr/gtiff` (repeated with different paths) specify where to search for source datasets. 
    Source datasets named by a relative path in the shapefile (`src_name` field) will be searched for in the paths 
    specified by `-p` options.
  - `-b 583000 589000 4226000 4230000`: specify the geographic bounds (xmin xmax ymin ymax) to render. This
    area will be broken up into tiles
    (by default 1000 pixels square), and rendered in pieces.  The bounds will be expanded to fall evenly on tile 
    boundaries, for example, even if xmin were specified as 583020, it would be rounded down to 583000.
  - `-vv`: doubly verbose.
  - `-r 2.0`: Set the render resolution. No reprojection is done, so this will be in the units of the projection 
    of the shapefile (which in turn is assumed to match the projection of any raster inputs).
    
## Defining sources
 
The shapefile defines what source datasets will be used and how to combine them.  It should be a polygon shapefile, in a square projection (i.e. UTM, rather than latitude/longitude).  The overall process is similar to working with layers
in image editing software -- source datasets are stacked up, with "higher" layers taking precedence over "lower" layers.
Note that "higher" and "lower" are in terms of _priority_, not elevation.

The important fields of the shapefile are:

 - _src_name_ By default this is interpreted as a filename for a raster dataset.  It can include wildcards (* or ?), 
  in which case all matching files will be used.  Filenames will be searched for in the current directory and any 
  paths specified with `-p` options.  If _src_name_ starts with `py:` then the rest of the field is interpreted
  as python code.  Currently the only viable code to include is `ConstantField(-1.234)` which will create a 
  constant-valued source dataset.
 - _data_mode_ This controls how data from the layer is used. By default, as each progressively higher layer is processed
  it simply replaces any overlapping values from lower layers.  Options can
  be combined with a comma. Current options are 
   - `min()` use the minimum of the value of this layer and the value from lower layers.
   - `max()` use the maximum of the value of this layer and the value from lower layers.
   - `fill(l)` fill holes in the source dataset up to `l` units wide.
 - _alpha_mode_ This controls how layers are blended. By default a layer, once processed according to data_mode, will
   simply overwrite the values from lower layers.  _alpha_mode_ allows some blending, with these options:
   - `valid()` - limit the layer to locations with valid data. If a high priority dataset has nan values in it, this
     will avoid writing those nans into the final DEM.  If the raster dataset has any nans, it is safest to include this
     as the first option.
   - `feather(l)` - blend this layer _in_ from the boundary by a distance _l_.
   - `feather_out(l)` - blend this layer _out_ from its boundary by a distance _l_.
 - _priority_  This dictates the order in which layers are processed.  The lowest priority is processed first, so that
   higher priority layers have the opportunity to overwrite the lower priority layers.
 
The shapefile in this repository additionally contains these fields:

 - _comment_  Exactly that.
 - _start_date_,_end_date_ To eventually support representing changes over time.  Rendering would be for
  a specific date, these fields will be used to omit certain layers that are not relevant for that
  specific date.
  

 
