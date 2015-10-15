library(NMF)
chr.palette <- c("darkred", "firebrick1", "pink1","darkorange3","darkorange","tan1","goldenrod3","gold","khaki","darkgreen","forestgreen","greenyellow","darkblue","dodgerblue","skyblue","darkslateblue","slateblue3","mediumpurple1","darkorchid4","orchid3","plum","violetred","grey31","grey0")



x <- as.matrix(read.table('/home/annashch/intermediate_results/features_filtered.tsv', header=TRUE, sep = "\t",row.names=1))
column_annotation<-c("6minuteWalk","6minuteWalk","6minuteWalk","6minuteWalk","6minuteWalk","6minuteWalk","6minuteWalk","6minuteWalk","ActivitySleep","ActivitySleep","ActivitySleep","ActivitySleep","ActivitySleep","ActivitySleep","ActivitySleep","ActivitySleep","CardiovascularDisplacement","DailyCheck","DailyCheck","DailyCheck","DailyCheck","DailyCheck","DailyCheck","DailyCheck","DailyCheck","DailyCheck","Demographic","Demographic","Demographic","Demographic","Diet","Diet","Diet","Diet","Diet","Diet","HealthKit","HealthKit","HealthKit","HealthKit","HealthKit","HealthKit","HealthKit","HealthKit","HealthKit","HealthKit","HealthKit","HealthKit","HeartAge","HeartAge","HeartAge","HeartAge","HeartAge","HeartAge","HeartAge","HeartAge","HeartAge","HeartAge","HeartAge/Demographics","HeartAge/Demographics","HeartAge/Demographics","MotionTracker","ParQ","ParQ","ParQ","ParQ","ParQ","ParQ","ParQ","RiskFactors","RiskFactors","RiskFactors","RiskFactors","Satisfaction","Satisfaction","Satisfaction","Satisfaction","Satisfaction","Satisfaction","Satisfaction","Satisfaction","Satisfaction","Satisfaction")
f_col_an=factor(column_annotation,levels=c("6minuteWalk","ActivitySleep","CardiovascularDisplacement","DailyCheck","Demographic","Diet","HealthKit","HeartAge","HeartAge/Demographics","MotionTracker","ParQ","RiskFactors","Satisfaction")) 


row_annotation<-c("4666","2579","2138","1100","500-1000","500-1000","500-1000","500-1000","500-1000","500-1000","500-1000","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","100-500","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","50-100","40-50","40-50","40-50","40-50","40-50","40-50","40-50","40-50","40-50","40-50","40-50","40-50","40-50","30-40","30-40","30-40","30-40","30-40","30-40","30-40","30-40","30-40","30-40","30-40","30-40","30-40","30-40","30-40","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","20-30","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20","10-20")

f_row_an=factor(row_annotation,levels=c("4666","2579","2138","1100","500-1000","100-500","50-100","40-50","30-40","20-30","10-20")) 
#browser()
pdf('/home/annashch/r_scripts/heatmap_improved.pdf') 
aheatmap(x, 
	    Rowv=NA,
	    Colv=TRUE,
	    main="My Heart Counts Data Availability",
	    sub="Red indicates available data, gray indicates missing data", 
	    annCol=list(metric=f_col_an),
	    annRow=list(number_of_subjects=f_row_an),
	    annColors=list(metrics=chr.palette[1:13],number_of_subjects=chr.palette[14:24]),
	    color=c("white","red"),
	    legend=FALSE)
dev.off() 

#pdf("../results/cna_heatmap.pdf",width=7,height=6)
#hm1 <- aheatmap(data.to.plot1, annLegend=c('column'),annCol=pheno2[,c("MaxLVWT","EF","LVOT_GT30")],annRow=cna.gene.matrix[,c("chr"),drop=F],
#annColors=list(chr=chr.palette),main="All Polymorphic CNA genes",color=c("Inversion"="yellow","Loss#"="dodgerblue1","Neutral"="grey97","Gain"="red"),
#border=list(annLegend=T,matrix=T,annRow=F,annCol=T),layout='_*',cexCol=0.3)


#library(gplots) 
#x <- as.matrix(read.table('/home/annashch/intermediate_results/feature_groups.tsv', header=TRUE, se#p = "\t",row.names=1,as.is=TRUE))
#heatmap2(x, Rowv=FALSE,  trace="none", density.info="none", 
#          dendrogram="none", xlab="feature pattern", ylab="number of subjects")
