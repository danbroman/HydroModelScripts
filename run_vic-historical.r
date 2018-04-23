#############################################################
# runs VIC using Livneh historic forcing data
#############################################################

## load libraries
library(dplyr)
library(stringr)
library(tidyr)
library(lubridate)
library(data.table)
library(tools)

## user inputs
setwd('/work/dbroman/projects/skokomish/run_vic/')
loca_run_list = scan('lib/loca_run_list.txt', what = 'character')
control_file = readLines('lib/global_control.412h.skokomish')
data_name = 'skokomish'

output_dir = paste0('data/output/livneh_historic/')
if(dir.exists(output_dir) == F){
	dir.create(output_dir)
}
control_file[17] = 'ENDYEAR     2013    # year model simulation ends'
control_file[43] = 'FORCING1 /data/vic/forcings/livneh_1_16/ascii/Meteorology_Livneh_NAmerExt_15Oct2014_'
	control_file[87] = 'RESULT_DIR /work/dbroman/projects/skokomish/run_vic/data/output/livneh_historic/'
write(control_file, paste0('lib/global_control.412h.livneh_historic.', data_name))
runcmd = paste0('src/VIC_4.1.2.h/src/vicNl -g lib/global_control.412h.livneh_historic.',
 data_name, ' > src/log-livneh_historic.txt 2>&1')
system(runcmd)
