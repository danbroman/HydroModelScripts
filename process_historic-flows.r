#############################################################
# processes VIC modeled historical flows for space-time disagg
# reads in raw files and reads out rdata files
#############################################################

## load libraries
library(dplyr)
library(tidyr)
library(data.table)
library(tools)

## user inputs
# setwd('C:/Users/dbroman/Projects/Salt River Project SRO/Analysis/Hydrology/VIC')
setwd('/work/dbroman/projects/salt_river_sro/run_vic/')
header_list = c('year', 'month', 'day', 'flow')

hstoric_sim = data.table()
run_sel = run_list[irun]
file_list = list.files(paste0('data/routed/livneh-historic/', run_sel), pattern = '*.day')
for(ifile in 1:length(file_list)){
	file_temp = file_list[ifile]
	name_temp = file_path_sans_ext(file_temp)	
	hstoric_sim_temp = fread(paste0('data/routed/livneh-historic/', file_temp)) %>% setNames(header_list)
	hstoric_sim_temp$sta_name = name_temp
	hstoric_sim_temp$run = run_sel
	hstoric_sim = bind_rows(hstoric_sim, hstoric_sim_temp)
}
saveRDS(hstoric_sim, 'data/processed/streamflow/historic_streamflow.rda')
