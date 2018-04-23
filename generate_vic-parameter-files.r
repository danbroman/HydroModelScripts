#===========================================================
# Name: Generate VIC Parameter Files
# Author: D. Broman, USBR Technical Service Center
# Last Modified: 2017-08-10
# Description: reads VIC soil and snow parameter files and
# keeps only study region. Want to clip veg file too, but haven't
# done this because of its format. VIC uses soil file to determine
# extent so this isn't necessary.
#===========================================================
library(data.table)
library(dplyr)
options(digits = 8)
#===========================================================
# User Inputs:

#- Working Directory
setwd('/work/dbroman/projects/skokomish/run_vic/')

#- Data Name (for output)
data_name = 'saltverde'

#- Extents [bounding box - bb; lon/lat pairs - lonlat]
extents_flag = 'lonlat'
# if 'bb' use these:
# longitude_file_path = 'lib/longitude_list.txt'
# latitude_file_path = 'lib/latitude_list.txt'
# if 'lonlat' use this:
extents_file_path = 'lib/coords.txt'

#- VIC Parameter File Paths
soil_file_path = '/data/vic/parameters/livneh/vic.nldas.mexico.snow.txt.L13'
veg_file_path = '/data/vic/parameters/livneh/vic.nldas.mexico.veg.txt'
snow_file_path = '/data/vic/parameters/livneh/vic.nldas.mexico.snow.txt.L13'
#===========================================================
# Read Inputs and Setup:
if(extents_flag == 'bb'){
        lon_vec = scan(longitude_file_path)
        lat_vec = scan(latitude_file_path)
        nlon = length(lon_vec)
        nlat = length(lat_vec)
        coord_tbl = data.table(lon = lon_vec,
          lat = rep(lat_vec, each = nlon)) %>%
        mutate(flag = 1)

} else if(extents_flag == 'lonlat'){
        coord_tbl = fread(extents_file_path) %>% mutate(flag = 1)
}

soil_file = fread(soil_file_path)
# veg_file = readLines(veg_file_path)
snow_file = fread(snow_file_path)

#===========================================================
# Process Files:
soil_file = soil_file %>%
  rename(lat = V3, lon = V4) %>%
  left_join(coord_tbl) %>% filter(flag == 1)
vicid_vec = soil_file$V2
snow_file = snow_file %>%
  filter(V1 %in% vicid_vec)

write.table(soil_file, paste0('lib/soil.', data_name), row.names = F,
  col.names = F, sep = ' ')
write.table(snow_file, paste0('lib/snow.', data_name), row.names = F,
  col.names = F, sep = ' ', quote = F)
