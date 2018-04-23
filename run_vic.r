#############################################################
# runs VIC
#############################################################

## load libraries
library(dplyr)
library(readr)
library(stringr)
library(tidyr)
library(lubridate)
library(data.table)
library(tools)
library(doParallel)
library(foreach)

## user inputs
setwd('/work/dbroman/projects/skokomish/run_vic/')
loca_run_list = scan('lib/loca_run_list.txt', what = 'character')
control_file = readLines('lib/global_control.412h.skokomish')
nclust = 4
data_name = 'skokomish'

## run setup
nruns = length(loca_run_list)
cl = makeCluster(nclust)
registerDoParallel(cl)
foreach(irun = 14:nruns) %dopar% {
	loca_run_sel = loca_run_list[irun]
	output_dir = paste0('data/output/', loca_run_sel)
	if(dir.exists(output_dir) == F){
		dir.create(output_dir)
	}
	control_file[43] = paste0('FORCING1 /work/dbroman/projects/skokomish/process_loca/data/processed/vic/',
		loca_run_sel,'/Meterology_LOCA_', data_name, '_', loca_run_sel, '_')
	control_file[87] = paste0('RESULT_DIR /work/dbroman/projects/skokomish/run_vic/data/output/',
		loca_run_sel, '/')
	write(control_file, paste0('lib/global_control.412h.', loca_run_sel, '.', data_name))
	runcmd = paste0('src/VIC_4.1.2.h/src/vicNl -g lib/global_control.412h.',
		loca_run_sel, '.', data_name, ' > src/log-', loca_run_sel, '.txt 2>&1')
	system(runcmd)
}
stopCluster(cl)
