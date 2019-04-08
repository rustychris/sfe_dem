rem Generate bathymetry at 2m in the vicinity of First
rem Mallard.

python -m stompy.spatial.generate_dem -s dem_sources.shp -o dem-fm-20190405 ^
 -p E:\proj\SFEstuary\SOURCE_DATA\Bathymetry\DWR\gtiff ^
 -p E:\proj\SFEstuary\PROCESSED_DATA\Bathymetry\NDelta_Hydro\NDelta_hydro_2m_v4 ^
 -p E:\proj\SFEstuary\PROCESSED_DATA\Bathymetry\Suisun_CMP\Source ^
 -b 583000 589000 4226000 4230000 -vv -r 2.0 -m