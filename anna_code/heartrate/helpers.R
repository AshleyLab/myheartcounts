#heart rate zones computed using the Zolodz method 
getZone = function(age){
  maxhr=191.5-(0.007*age^2)
  z5_start=maxhr*.9 
  z5_end = maxhr 
  z4_start=maxhr*.8 
  z4_end=z5_start 
  z3_start=maxhr*.7 
  z3_end=z4_start 
  z2_start=maxhr*.6
  z2_end=z3_start
  z1_start=maxhr*.5
  z1_end=z2_start 
  zones=as.data.frame(rbind(c(z1_start,z2_start,z3_start,z4_start,z5_start),c(z1_end,z2_end,z3_end,z4_end,z5_end)))
  setnames(zones,c("V1","V2","V3","V4","V5"),c("z1","z2","z3","z4","z5"))
  return(zones)
}
