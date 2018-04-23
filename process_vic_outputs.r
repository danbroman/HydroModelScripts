
#############################################################
# spatially averages outputs other than streamflow
#############################################################

## load libraries
library(dplyr)
# library(readr)
library(stringr)
library(tidyr)
library(lubridate)
library(data.table)
library(tools)
library(doParallel)
library(foreach)

## user inputs
setwd('/work/dbroman/projects/skokomish/run_vic')
loca_run_list = scan('lib/loca_run_list.txt', what = 'character')
longitude_list = scan('lib/longitude_list.txt')
latitude_list = scan('lib/latitude_list.txt')
date_vec = seq(from = as.Date('1950-01-01'), to = as.Date('2099-12-31'), by = 'day')
date_vec_historic = seq(from = as.Date('1950-01-01'),
	to = as.Date('2013-12-31'), by = 'day')

nlon = length(longitude_list)
nlat = length(latitude_list)

nproj = length(loca_run_list)
coord_tbl = data.table(lon = longitude_list,
	lat = rep(latitude_list, each = nlon))
nfiles = nrow(coord_tbl)

# swe
dat_future = data.table()
for(i in 1:nproj){
	proj_sel = loca_run_list[i]
	filepath_temp = paste0('data/output/', proj_sel, '/')
	dat_proj = data.table()
	for(j in 1:nfiles){
		lon_sel = coord_tbl$lon[j]
		lat_sel = coord_tbl$lat[j]
		dat_temp = data.table(value = fread(paste0(filepath_temp,
			'snow_', lat_sel, '_', lon_sel))$V5, lon = lon_sel, lat = lat_sel)
		dat_proj = bind_rows(dat_proj, dat_temp)
	}
	dat_proj$date = date_vec
	dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))
	dat_proj$proj = proj_sel
	dat_future = bind_rows(dat_future, dat_proj)
}
dat_future_sp = dat_future %>% spread(proj, value)
write.csv(dat_future_sp, 'data/processed/spatial_avg/swe_future.csv',
	row.names = F, quote = F)
#sm
dat_future = data.table()
for(i in 1:nproj){
	proj_sel = loca_run_list[i]
	filepath_temp = paste0('data/output/', proj_sel, '/')
	dat_proj = data.table()
	for(j in 1:nfiles){
		lon_sel = coord_tbl$lon[j]
		lat_sel = coord_tbl$lat[j]
		dat_temp = data.table(value = fread(paste0(filepath_temp, 'etsm_',
			lat_sel, '_', lon_sel))$V10, lon = lon_sel, lat = lat_sel)
		dat_proj = bind_rows(dat_proj, dat_temp)
	}
	dat_proj$date = date_vec
	dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))
	dat_proj$proj = proj_sel
	dat_future = bind_rows(dat_future, dat_proj)
}
dat_future_sp = dat_future %>% spread(proj, value)
write.csv(dat_future_sp, 'data/processed/spatial_avg/sm_future.csv',
	row.names = F, quote = F)

#aet
dat_future = data.table()
for(i in 1:nproj){
	proj_sel = loca_run_list[i]
	filepath_temp = paste0('data/output/', proj_sel, '/')
	dat_proj = data.table()
	for(j in 1:nfiles){
		lon_sel = coord_tbl$lon[j]
		lat_sel = coord_tbl$lat[j]
		dat_temp = data.table(value = fread(paste0(filepath_temp, 'etsm_',
			lat_sel, '_', lon_sel))$V4, lon = lon_sel, lat = lat_sel)
		dat_proj = bind_rows(dat_proj, dat_temp)
	}
	dat_proj$date = date_vec
	dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))
	dat_proj$proj = proj_sel
	dat_future = bind_rows(dat_future, dat_proj)
}
dat_future_sp = dat_future %>% spread(proj, value)
write.csv(dat_future_sp, 'data/processed/spatial_avg/aet_future.csv',
	row.names = F, quote = F)

#pet (short-grass reference)
dat_future = data.table()
for(i in 1:nproj){
	proj_sel = loca_run_list[i]
	filepath_temp = paste0('data/output/', proj_sel, '/')
	dat_proj = data.table()
	for(j in 1:nfiles){
		lon_sel = coord_tbl$lon[j]
		lat_sel = coord_tbl$lat[j]
		dat_temp = data.table(value = fread(paste0(filepath_temp, 'etsm_',
			lat_sel, '_', lon_sel))$V7, lon = lon_sel, lat = lat_sel)
		dat_proj = bind_rows(dat_proj, dat_temp)
	}
	dat_proj$date = date_vec
	dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))
	dat_proj$proj = proj_sel
	dat_future = bind_rows(dat_future, dat_proj)
}
dat_future_sp = dat_future %>% spread(proj, value)
write.csv(dat_future_sp, 'data/processed/spatial_avg/pet_future.csv',
	row.names = F, quote = F)

# swe (historic)
filepath_temp = paste0('data/output/livneh_historic/')
dat_proj = data.table()
for(j in 1:nfiles){
	lon_sel = coord_tbl$lon[j]
	lat_sel = coord_tbl$lat[j]
	dat_temp = data.table(value = fread(paste0(filepath_temp, 'snow_',
		lat_sel, '_', lon_sel))$V5, lon = lon_sel, lat = lat_sel)
	dat_proj = bind_rows(dat_proj, dat_temp)
}
dat_proj$date = date_vec_historic
dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))

dat_historic = data.table(historic = dat_proj$value)
write.csv(dat_historic, 'data/processed/spatial_avg/swe_historic.csv',
	row.names = F, quote = F)

# sm (historic)
filepath_temp = paste0('data/output/livneh_historic/')
dat_proj = data.table()
for(j in 1:nfiles){
	lon_sel = coord_tbl$lon[j]
	lat_sel = coord_tbl$lat[j]
	dat_temp = data.table(value = fread(paste0(filepath_temp, 'etsm_',
		lat_sel, '_', lon_sel))$V10, lon = lon_sel, lat = lat_sel)
	dat_proj = bind_rows(dat_proj, dat_temp)
}
dat_proj$date = date_vec_historic
dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))

dat_historic = data.table(historic = dat_proj$value)
write.csv(dat_historic, 'data/processed/spatial_avg/sm_historic.csv',
	row.names = F, quote = F)

# aet (historic)
filepath_temp = paste0('data/output/livneh_historic/')
dat_proj = data.table()
for(j in 1:nfiles){
	lon_sel = coord_tbl$lon[j]
	lat_sel = coord_tbl$lat[j]
	dat_temp = data.table(value = fread(paste0(filepath_temp, 'etsm_',
		lat_sel, '_', lon_sel))$V4, lon = lon_sel, lat = lat_sel)
	dat_proj = bind_rows(dat_proj, dat_temp)
}
dat_proj$date = date_vec_historic
dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))

dat_historic = data.table(historic = dat_proj$value)
write.csv(dat_historic, 'data/processed/spatial_avg/aet_historic.csv', row.names = F, quote = F)

# pet (historic)
filepath_temp = paste0('data/output/livneh_historic/')
dat_proj = data.table()
for(j in 1:nfiles){
	lon_sel = coord_tbl$lon[j]
	lat_sel = coord_tbl$lat[j]
	dat_temp = data.table(value = fread(paste0(filepath_temp, 'etsm_',
		lat_sel, '_', lon_sel))$V7, lon = lon_sel, lat = lat_sel)
	dat_proj = bind_rows(dat_proj, dat_temp)
}
dat_proj$date = date_vec_historic
dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))

dat_historic = data.table(historic = dat_proj$value)
write.csv(dat_historic, 'data/processed/spatial_avg/pet_historic.csv',
	row.names = F, quote = F)






#precip
dat_future = data.table()
for(i in 1:nproj){
	proj_sel = loca_run_list[i]
	filepath_temp = paste0('/work/dbroman/projects/skokomish/process_loca/data/processed/vic/', proj_sel, '/Meterology_LOCA_skokomish_', proj_sel, '_')
	dat_proj = data.table()
	for(j in 1:nfiles){
		lon_sel = coord_tbl$lon[j]
		lat_sel = coord_tbl$lat[j]
		dat_temp = data.table(value = fread(paste0(filepath_temp, lat_sel, '_', lon_sel))$V1, lon = lon_sel, lat = lat_sel)
		dat_proj = bind_rows(dat_proj, dat_temp)
	}
	dat_proj$date = date_vec
	dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))
	dat_proj$proj = proj_sel
	dat_future = bind_rows(dat_future, dat_proj)
}
dat_future_sp = dat_future %>% spread(proj, value)
write.csv(dat_future_sp, 'data/processed/spatial_avg/precip_future.csv', row.names = F, quote = F)

#max temperature
dat_future = data.table()
for(i in 1:nproj){
	proj_sel = loca_run_list[i]
	filepath_temp = paste0('/work/dbroman/projects/skokomish/process_loca/data/processed/vic/', proj_sel, '/Meterology_LOCA_skokomish_', proj_sel, '_')
	dat_proj = data.table()
	for(j in 1:nfiles){
		lon_sel = coord_tbl$lon[j]
		lat_sel = coord_tbl$lat[j]
		dat_temp = data.table(value = fread(paste0(filepath_temp, lat_sel, '_', lon_sel))$V2, lon = lon_sel, lat = lat_sel)
		dat_proj = bind_rows(dat_proj, dat_temp)
	}
	dat_proj$date = date_vec
	dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))
	dat_proj$proj = proj_sel
	dat_future = bind_rows(dat_future, dat_proj)
}
dat_future_sp = dat_future %>% spread(proj, value)
write.csv(dat_future_sp, 'data/processed/spatial_avg/tmax_future.csv', row.names = F, quote = F)

#min temperature
dat_future = data.table()
for(i in 1:nproj){
	proj_sel = loca_run_list[i]
	filepath_temp = paste0('/work/dbroman/projects/skokomish/process_loca/data/processed/vic/',
		proj_sel, '/Meterology_LOCA_skokomish_', proj_sel, '_')
	dat_proj = data.table()
	for(j in 1:nfiles){
		lon_sel = coord_tbl$lon[j]
		lat_sel = coord_tbl$lat[j]
		dat_temp = data.table(value = fread(paste0(filepath_temp, lat_sel, '_', lon_sel))$V3,
			lon = lon_sel, lat = lat_sel)
		dat_proj = bind_rows(dat_proj, dat_temp)
	}
	dat_proj$date = date_vec
	dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))
	dat_proj$proj = proj_sel
	dat_future = bind_rows(dat_future, dat_proj)
}
dat_future_sp = dat_future %>% spread(proj, value)
write.csv(dat_future_sp, 'data/processed/spatial_avg/tmin_future.csv',
	row.names = F, quote = F)

# precip (historic)
filepath_temp = '/data/vic/forcings/livneh_1_16/ascii/Meteorology_Livneh_NAmerExt_15Oct2014_'
dat_proj = data.table()
for(j in 1:nfiles){
	lon_sel = coord_tbl$lon[j]
	lat_sel = coord_tbl$lat[j]
	dat_temp = data.table(value = fread(paste0(filepath_temp, lat_sel, '_', lon_sel))$V1,
		lon = lon_sel, lat = lat_sel)
	dat_proj = bind_rows(dat_proj, dat_temp)
}
dat_proj$date = date_vec_historic
dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))

dat_historic = data.table(historic = dat_proj$value)
write.csv(dat_historic, 'data/processed/spatial_avg/precip_historic.csv',
	row.names = F, quote = F)

# tmax (historic)
filepath_temp = '/data/vic/forcings/livneh_1_16/ascii/Meteorology_Livneh_NAmerExt_15Oct2014_'
dat_proj = data.table()
for(j in 1:nfiles){
	lon_sel = coord_tbl$lon[j]
	lat_sel = coord_tbl$lat[j]
	dat_temp = data.table(value = fread(paste0(filepath_temp, lat_sel, '_', lon_sel))$V2,
		lon = lon_sel, lat = lat_sel)
	dat_proj = bind_rows(dat_proj, dat_temp)
}
dat_proj$date = date_vec_historic
dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))

dat_historic = data.table(historic = dat_proj$value)
write.csv(dat_historic, 'data/processed/spatial_avg/tmax_historic.csv',
	row.names = F, quote = F)

# tmin (historic)
filepath_temp = '/data/vic/forcings/livneh_1_16/ascii/Meteorology_Livneh_NAmerExt_15Oct2014_'
dat_proj = data.table()
for(j in 1:nfiles){
	lon_sel = coord_tbl$lon[j]
	lat_sel = coord_tbl$lat[j]
	dat_temp = data.table(value = fread(paste0(filepath_temp, lat_sel, '_', lon_sel))$V2,
		lon = lon_sel, lat = lat_sel)
	dat_proj = bind_rows(dat_proj, dat_temp)
}
dat_proj$date = date_vec_historic
dat_proj = dat_proj %>% group_by(date) %>% summarise(value = mean(value))

dat_historic = data.table(historic = dat_proj$value)
write.csv(dat_historic, 'data/processed/spatial_avg/tmin_historic.csv',
	row.names = F, quote = F)
