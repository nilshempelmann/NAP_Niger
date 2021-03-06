# R skript for bias adjustment of CORDEX climate data ( Niger subset ) 
# install.packages("CDFt")

library(RColorBrewer)
library(CDFt)
library(ncdf4)
library(stringr)

######################################
# function for bias adjustment 
bias_adjust <- function(obs_val, ref_val, model_val){
  model_adjust <- array(numeric(),c(dim(model_val)))
  for (r in 1:nrow(obs_val))   
  { for (c in 1:ncol(obs_val))
    { val_aj <- CDFt(obs_val[r,c,], ref_val[r,c,], model_val[r,c,], npas=100, dev=2)
    model_adjust[r,c,] <- c(val_aj$DS)
    }
  }
return(model_adjust)}

######################################
# get the values (observation, historical run and corresponding RCP.)


# fs_obs <- c('tas_AFR-22_ECMWF-ERAINT_evaluation_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19790101-20161231.nc',
#             'tas_AFR-22_ECMWF-ERAINT_evaluation_r1i1p1_GERICS-REMO2015_v1_day_19790102-20171231.nc')
# 
# fs_hist <- c('tas_AFR-22_MOHC-HadGEM2-ES_historical_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19500101-20051230.nc', 
#             'tas_AFR-22_MPI-M-MPI-ESM-LR_historical_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19500101-20051231.nc',
#             'tas_AFR-22_NCC-NorESM1-M_historical_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19500101-20051231.nc',
#             'tas_AFR-22_MOHC-HadGEM2-ES_historical_r1i1p1_GERICS-REMO2015_v1_day_19700101-20051230.nc' )
# 
# fs_rcp26 <- c('tas_AFR-22_MOHC-HadGEM2-ES_rcp26_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_20060101-20981230.nc',
#              'tas_AFR-22_MOHC-HadGEM2-ES_rcp26_r1i1p1_GERICS-REMO2015_v1_day_20060101-20991230.nc',
#              'tas_AFR-22_MPI-M-MPI-ESM-LR_rcp26_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_20060101-21001231.nc'
#              )
# 
# fs_rcp85 <- c('tas_AFR-22_MOHC-HadGEM2-ES_rcp85_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_20060101-20991230.nc')
# 


fs_obs <- c('pr_AFR-22_ECMWF-ERAINT_evaluation_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19790101-20161231.nc',
            'pr_AFR-22_ECMWF-ERAINT_evaluation_r1i1p1_GERICS-REMO2015_v1_day_19790102-20171231.nc')

fs_hist <- c('pr_AFR-22_MOHC-HadGEM2-ES_historical_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19500101-20051230.nc', 
             'pr_AFR-22_MPI-M-MPI-ESM-LR_historical_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19500101-20051231.nc',
             'pr_AFR-22_NCC-NorESM1-M_historical_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_19500101-20051231.nc',
             'pr_AFR-22_MOHC-HadGEM2-ES_historical_r1i1p1_GERICS-REMO2015_v1_day_19700101-20051230.nc' )

fs_rcp26 <- c('pr_AFR-22_MOHC-HadGEM2-ES_rcp26_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_20060101-20981230.nc',
              'pr_AFR-22_MOHC-HadGEM2-ES_rcp26_r1i1p1_GERICS-REMO2015_v1_day_20060101-20991230.nc',
              'pr_AFR-22_MPI-M-MPI-ESM-LR_rcp26_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_20060101-21001231.nc'
)

fs_rcp85 <- c('pr_AFR-22_MOHC-HadGEM2-ES_rcp85_r1i1p1_CLMcom-KIT-CCLM5-0-15_v1_day_20060101-20991230.nc')


path <- '../data/bbox/'
pathAj <- '../data/adjust/'
varname <- 'prAdjust'

f_obs <- paste(path, fs_obs[1],  sep="")
f_ref <- paste(path, fs_hist[1],  sep="")

f_mod <- paste(path, fs_hist[1],  sep="")
f_modAj <- paste(pathAj, str_replace(fs_hist[1], 'pr_', 'prAdjust_'),  sep="")


# open files and read in the data 

# open the netCDF files
nc_obs <- nc_open(f_obs)
nc_ref <- nc_open(f_ref)
nc_mod <- nc_open(f_mod)

# read in the values: 
# get temperature
pr_obs <- ncvar_get(nc_obs,'pr')
pr_ref <- ncvar_get(nc_ref,'pr')
pr_mod <- ncvar_get(nc_mod,'pr')

# make the bias Adjustment 

pr_modAj <- bias_adjust(pr_obs, pr_ref, pr_mod)

# make a quick plot to check
image(pr_obs[,,1], col=rev(brewer.pal(11,"RdBu")))
plot.default(pr_modAj[1,1,])
image(pr_mod[,,1] - pr_modAj[,,1],  col=rev(brewer.pal(11,"RdBu")))

ts_obs <- apply(pr_obs, 3, mean)
ts_ref <- apply(pr_ref, 3, mean)
ts_modadj <- apply(pr_modAj, 3, mean)
plot(seq(length(ts_obs)), ts_obs,type="l")
lines(seq(length(ts_ref)), ts_ref, col="red", lwd=1)
lines(seq(length(ts_modadj)), ts_modadj, col="blue", lwd=1)

# create Adjust output file and store the values there 

copy_message <- file.copy(f_mod, f_modAj )
print(copy_message)

nc_modAj <- nc_open(f_modAj, write=TRUE)

var_prAj <- ncvar_def( 'pr', nc_mod$var$pr$units , nc_mod$var$pr$dim , nc_mod$var$pr$missval, longname = nc_mod$var$pr$longname, prec="float", 
           shuffle=FALSE, compression=NA, chunksizes=NA, verbose=FALSE )

ncvar_put( nc_modAj , var_prAj, pr_modAj, start=NA, count=NA, verbose=FALSE )

nc_close(nc_modAj)
