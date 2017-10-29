# Loading packages ----
library(rgdal)
library(raster)
library(rgeos)
library(RColorBrewer)

# Getting data from Worldclim.com ----
?getData

# current climatic variable
#World <- getData('worldclim', var='bio', res=2.5)
mt <- readOGR(dsn='./shp', layer = 'MT')
#mt_current <- crop(World, mt)
#mt_current <- mask(mt_current, mt)
#plot(mt_current[[2]])

WorldT <- getData('worldclim', var='tmean', res=2.5)
mt_currentT <- crop(WorldT, mt)
mt_currentT <- mask(mt_currentT, mt)

# Future (Climate Change) rcp=8.5, model=HE year=50
world_2.5_85_50 <- getData('CMIP5', var='bio', res=2.5, rcp=85, model='HE', year=50)

world_2.5_85_50 <- crop(world_2.5_85_50, mt)
world_2.5_85_50 <- mask(world_2.5_85_50, mt)

# Future (Climate Change) rcp=2.6, model=HE year=50
# Download from website
# world_2.5_26_50 <- getData('CMIP5', var='bio', res=2.5, rcp=26, model='HE', year=50)
world_2.5_26_50 <- stack(list.files('./he26bi50/', full.names = TRUE))

world_2.5_26_50 <- crop(world_2.5_26_50, mt)
world_2.5_26_50 <- mask(world_2.5_26_50, mt)

# Saving rasters for MT ----
?writeRaster

# Current
writeRaster(mt_clim, filename = paste0('./raster/MT_current_',names(mt_clim)), format='GTiff', bylayer=TRUE, overwrite=TRUE)

# Future 2050 rcp 85
writeRaster(world_2.5_85_50, filename = paste0('./raster/MT_fut_85_50_',names(mt_clim)), format='GTiff', bylayer=TRUE, overwrite=TRUE)

# Future 2050 rcp 26
writeRaster(world_2.5_26_50, filename = paste0('./raster/MT_fut_26_50_',names(mt_clim)), format='GTiff', bylayer=TRUE, overwrite=TRUE)

# Producing PET for each scenario ---

# T is the average daily temperature (degrees Celsius; if this is negative, use 0) of the month being calculated
svg_day_length <- 
# N is the number of days in the month being calculated
n_days <- 
# L is the average day length (hours) of the month being calculated
avg_day_temp <- 
  
# PET = 16 ( L 12 ) ( N 30 ) ( 10 T a I ) α {\displaystyle PET=16\left({\frac {L}{12}}\right)\left({\frac {N}{30}}\right)\left({\frac {10\,T_{a}}{I}}\right)^{\alpha }}


# Producing Cluster analysis for MT ----
# mt_current <- stack(list.files('./raster/', full.names=TRUE, pattern='MT_current_'))

source('../SegmentationFCT/segmentation.R')
args(segmentation)

# Homogeneous Response Unity
MT_hru <- segmentation(envLayer = mt_current, studyArea = mt, projName = 'MT_MT_hru', folder = './Out/', randomforest = FALSE, Kmeans = FALSE, fuzzy.cluster = TRUE, random.pt = NULL, ngroup = 20, save.shp = TRUE, save.raster = TRUE, save.plot = FALSE, save.fit = TRUE, seed=123)

# MT_hru <- raster('./MT_MT_hru.tif')
plot(MT_MT_hru)


source('./precAnalysis.R')
args(precAnalysis)

precAnalysis(envLayer = MT_prec,
             zones = MT_20,
             stats = c('mean','sd'),
             projName = 'MT_yr_prec_current')


MT_prec_50_85 <- stack('./raster/MT_prec_HE_50_85_2.5.tif')

segmentation(envLayer = MT_prec_50_85, #raster Layer or raster stack
             studyArea = MT, # SpatialPolygonsDataFrame
             randomforest = TRUE,
             projName = 'MT_prec_50_85_zones',
             random.pt = NULL, # Number of random points to be genarated to run randomForest
             Kmeans = FALSE,
             ngroup = NULL, # Number of classes to be classified
             polygonize = FALSE,
             seed=123)

MT_20_future <- raster('./rf_segmentation_MT_prec_50_85_zones.tif')
plot(MT_20_future)

precAnalysis(envLayer = MT_prec_50_85,
             zones = MT_20_future,
             stats = c('mean','sd'),
             projName = 'MT_yr_prec_HE_50')
