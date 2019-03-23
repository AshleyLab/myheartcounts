rm(list=ls())
library(ggplot2)
library(randomForest)
library(onehot)
library(Hmisc)
library(corrplot)
library(gplots)


df=read.table("merged.tsv",header=TRUE,sep='\t')

#drop any columns that are composed of NA entirely
df=df[colSums(is.na(df)) < nrow(df)]

#fill in missing values via imputation
df <- na.roughfix(df)

#remove any columns with zero variance
df=df[sapply(df,var)>0]

encoder=onehot(df)
onehot_df <- predict(encoder,df)

#compute correlation matrix (spearman)
spearman_cor <- rcorr(as.matrix(onehot_df),type=c("spearman"))
write.table(spearman_cor$r,file="SpearmanCorrelation.tsv",col.names=TRUE,row.names=TRUE,sep='\t')
#compute correlation matrix (pearson)
pearson_cor <- rcorr(as.matrix(onehot_df),type=c("pearson"))
write.table(pearson_cor$r,file="PearsonCorrelation.tsv",col.names=TRUE,row.names=TRUE,sep='\t')


svg("SpearmanCorr.svg",height=20,width=20)
print(corrplot(spearman_cor$r, type="upper", order="hclust",
               p.mat = spearman_cor$P, sig.level = 0.01, insig = "blank", tl.col = "black", tl.srt = 45,tl.cex = 0.5))
dev.off()

svg("PearsonCorrNEIL1.svg",height=20,width=20)
print(corrplot(pearson_cor$r, type="upper", order="hclust",
               p.mat = pearson_cor$P, sig.level = 0.01, insig = "blank", tl.col = "black", tl.srt = 45,tl.cex = 0.5))
dev.off()

col<- colorRampPalette(c('#67001f','#b2182b','#d6604d','#f4a582','#fddbc7','#d1e5f0','#92c5de','#4393c3','#2166ac','#053061'))(100)
svg("SpearmanHeatmap.svg",height=20,width=20)
print(heatmap.2(as.matrix(spearman_cor$r),
                col=col,
                Rowv=TRUE,
                Colv=TRUE,
                scale="none",
                trace="none",
                margins = c(20,20)
))
dev.off()

svg("PearsonHeatmap.svg",height=20,width=20)
print(heatmap.2(as.matrix(pearson_cor$r),
                col=col,
                Rowv=TRUE,
                Colv=TRUE,
                scale="none",
                trace="none",
                margins=c(20,20)
))
dev.off()





# df$atwork=factor(df$atwork)
# ggplot(df,
#        aes(x=df$atwork,
#            y=df$MeanDailySteps))+
#   geom_boxplot()+
#   xlab("Activity at Work")+
#   ylab("Mean Daily Step Count")+
#   ylim(0,25000)
