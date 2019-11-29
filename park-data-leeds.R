
devtools::install_github("itsleeds/geofabric")
mapview::mapview(geofabric::geofabric_zones)
library(geofabric)
region_data = geofabric::get_geofabric(name = "West Yorkshire", layer = "multipolygons")
file_name = gf_filename("West Yorkshire")
file.exists(file_name)
mapview::mapview(region_data)
query = "select leisure from multipolygons where leisure = 'park'"
region_data = sf::st_read(dsn = file_name, layer = "multipolygons", options = "OGR_INTERLEAVED_READING=YES", query = query)
saveRDS(region_data, "parks-west-yorkshire.Rds")
sf::write_sf(region_data, "parks-west-yorkshire.geojson")

piggyback::pb_new_release(tag = "0.0.1")
piggyback::pb_upload("parks-west-yorkshire.Rds")
piggyback::pb_upload("parks-west-yorkshire.geojson")

region_data = read_pbf()

library(bench)

rds = function() readRDS("parks-west-yorkshire.Rds")
sfr = function() sf::read_sf("parks-west-yorkshire.geojson")
gsf = function() geojsonsf::geojson_sf("parks-west-yorkshire.geojson")


res = bench::mark(check = F,
            rds(),
            sfr(),
            gsf()
            )

plot(res)

# attempt with osmdata (failed) -------------------------------------------

library(osmdata)
osm_parks = opq("Leeds") %>% 
  add_osm_feature(key = "leisure", value = "park") %>% 
  osmdata_sf()
