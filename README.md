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
    
 
