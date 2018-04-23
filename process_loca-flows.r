#############################################################
# processes VIC flows using LOCA forcings
# reads in raw files and reads out rdata files
#############################################################

## load libraries
library(dplyr)
library(tidyr)
library(data.table)
library(tools)

## user inputs
setwd('/work/dbroman/projects/skokomish/run_vic/')
header_list = c('year', 'month', 'day', 'flow')

run_list = list.files('data/routed/')
nruns = length(run_list)
loca_sim = data.table()
for(irun in 1:nruns){
	run_sel = run_list[irun]
	file_list = list.files(paste0('data/routed/', run_sel), pattern = '*.day')
	for(ifile in 1:length(file_list)){
		file_temp = file_list[ifile]
		name_temp = file_path_sans_ext(file_temp)
		loca_sim_temp = fread(paste0('data/routed/', run_sel, '/', file_temp)) %>%
			setNames(header_list)
		loca_sim_temp$sta_name = name_temp
		loca_sim_temp$run = run_sel
		loca_sim = bind_rows(loca_sim, loca_sim_temp)
	}
}
loca_sim = setNames(loca_sim, c(header_list, 'sta_id'))
loca_sim = loca_sim %>% mutate(year = wyear_yearmon(year, month))

saveRDS(loca_sim, 'data/processed/streamflow/loca_streamflow.rda')
