### Analysis of the Accuracy of the Six Minute Walk ###
setwd("~/Documents/AshleyLab/MHealth")
sixval = read.csv("Copy of SIX MINUTE WALK TESTS MHC.csv")
library(ggplot2)
corr = cor.test(sixval$APP , sixval$MEASURED)
corr

sixval_noFast = sixval[1:13,]
corr_noFast = cor.test(sixval_noFast$APP, sixval_noFast$MEASURED)

sixval$SCALED_ERROR = abs(sixval$DIFFERENCE)/sixval$MEASURED
mean(sixval$SCALED_ERROR)

sixval_noFast$SCALED_ERROR = abs(sixval_noFast$DIFFERENCE)/sixval_noFast$MEASURED
mean(sixval_noFast$SCALED_ERROR)

sixval$MEANOBS = (sixval$APP + sixval$MEASURED)/2

plot(sixval$DIFFERENCE ~ sixval$MEANOBS, pch=20, ylab="Difference (feet)", xlab="Mean Observation")
abline(h=0, col="red", lty=2)
abline(h=mean(sixval$DIFFERENCE)-c(-2,2)*sd(sixval$DIFFERENCE), lty=2, col="blue")


plot(y=sixval_noFast$DIFFERENCE/3, x=sixval_noFast$MEANOBS/3, pch=20, ylab="Difference (yards)", xlab="Mean Observation", ylim=c(-200,200))
abline(h=0, col="red", lty=2)
abline(h=mean(sixval_noFast$DIFFERENCE)/3-c(-2,2)*sd(sixval_noFast$DIFFERENCE)/3, lty=2, col="blue")

plot(y=sixval_noFast$APP/3, x=sixval_noFast$MEASURED/3, pch=20, ylab="App Yards", xlab="Actual Yards")
abline(a=0, b=1, lty=2, col="red")


### Most up to date values

sixmin = read.csv("sixMinValidation.csv")
cor(sixmin$AppReported, sixmin$Measured)
cor(sixmin$AppReported, sixmin$Measured, method="spearman")

cor.test(sixmin$AppReported, sixmin$Measured)
pdf("SixMin_BlandAltman071415.pdf", width=7, height=6)
plot(y=sixmin$Difference, x=sixmin$Measured, pch=20, ylab="Error (yards)", xlab="Measured Distance (yards)", ylim=c(-200,200), main="Six Minute Walk")
abline(h=mean(sixmin$Difference), col="red", lty=2)
abline(h=mean(sixmin$Difference)+c(2,-2)*sd(sixmin$Difference), lty=2, col="blue")
legend("topright", legend=c("Mean", "2 SD"), col=c("red", "blue"), lty=2)
dev.off()

pdf("sixMin_correlation071415.pdf", width=7, height=6)
plot(sixmin$AppReported ~ sixmin$Measured, pch=20, xlab="Measured", ylab="Reported", xlim=c(450,750), ylim=c(450,750))
abline(a=0, b=1, lty=2, col="red")
legend("topleft", legend="1:1 Line", col="red", lty=2)
dev.off()

pdf("sixMin_correlation071415_zero.pdf", width=7, height=6)
plot(sixmin$AppReported ~ sixmin$Measured, pch=20, xlab="Measured", ylab="Reported", xlim=c(0,750), ylim=c(0,750))
abline(a=0, b=1, lty=2, col="red")
legend("topleft", legend="1:1 Line", col="red", lty=2)
dev.off()

mean(sixmin$PercDiff)

summary(lm(sixmin$AppReported ~ sixmin$Measured))


outside = subset(sixmin, Outside)
pdf("outsideCorr_071415_longAxis.pdf", height=6, width=6)
plot(outside$AppReported ~ outside$Measured, pch=20, xlab="Measured", ylab="Reported", xlim=c(450,750), ylim=c(450,750))
abline(a=0, b=1, lty=2, col="red")
dev.off()

pdf("outsideBA_plot_071415.pdf", height=6, width=7)
plot(y=outside$Difference, x=outside$Measured, pch=20, ylab="Error (yards)", xlab="Measured Distance (yards)", ylim=c(-200,200), main="Six Minute Walk - Outside Validations")
abline(h=mean(outside$Difference), col="red", lty=2)
abline(h=mean(outside$Difference)+c(2,-2)*sd(outside$Difference), lty=2, col="blue")
legend("topright", legend=c("Mean", "2 SD"), col=c("red", "blue"), lty=2)
dev.off()

ggplot(aes(x=Measured, y=AppReported, color=TestType), data=sixmin) + geom_point(size=3) + theme_bw() + geom_abline(a=0, b=1, lty=2) + xlim(c(450, 750)) + ylim(c(450,750))
ggsave("CorrelationByTestType_071415.pdf", height=6, width=9)
