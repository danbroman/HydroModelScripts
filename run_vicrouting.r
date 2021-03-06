#############################################################
# runs VIC Fortran routing code
# note: there are two uh_s files. one from the basin delineation
# and a second generated by this code. the first points to the second
# uh_s file - station file
# uh_s file from Tom points to the station file. Initally this doesn't
# exist and the routing code uses the none file.
# the default in Tom's code is uh_s/XXX.uh_s as a location for these
# generated files. if the default location is different, the
# pointer uh_s files need to be edited first.

#############################################################

## user inputs
setwd('/work/dbroman/projects/skokomish/run_vic/')
loca_run_list = scan('lib/loca_run_list.txt', what = 'character')
route_list = scan('lib/route_list.txt', what = 'character')
control_file = readLines('lib/routectrl.inp')
data_name = 'skokomish'

nruns = length(loca_run_list)
nroute = length(route_list)
for(irun in 1:nruns) {
        loca_run_sel = loca_run_list[irun]
        output_dir = paste0('data/routed/', loca_run_sel, '/')
        if(dir.exists(output_dir) == F){
                dir.create(output_dir)
        }
        for(iroute in 1:nroute){
                route_sel = route_list[iroute]
                uh_file = paste0(route_sel, '.uh_s')
                log_file = paste0('logs/log-route-', loca_run_sel, '-',
                  route_sel, '.txt')
                control_file[3] = paste0('data/processed/route/',
                  route_sel,'.fdir')
                control_file[15] = paste0('data/processed/route/',
                  route_sel,'.frac')
                if(file.exists(uh_file) == FALSE){
                  control_file[17] = paste0('data/processed/route/',
                    route_sel,'.none')
                } else {
                       control_file[17] = paste0('data/processed/route/', route_sel,'.uh_s')
                }
                control_file[19] = paste0('data/output/', loca_run_sel,'/hydro_')
                control_file[22] = paste0(output_dir)

                write(control_file, paste0('lib/routectrl.', loca_run_sel, '.',
                  route_sel, '.', data_name, '.inp'))
                runcmd = paste0('./src/rout_f77/rout lib/routectrl.',
                  loca_run_sel, '.', route_sel, '.', data_name, '.inp')
                 # ' > ',  log_file,' 2>&1 &')
                system(runcmd)
        }
}
system(paste0('mv *.uh_s data/processed/route/uh_s/'))
