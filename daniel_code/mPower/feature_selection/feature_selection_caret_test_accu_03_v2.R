#source("~/mybiotools/r/dp_try_part2.R", echo=T)
#use independent test data find the best model with accuracy
#based on results of "feature_selection_rf_svm_screen_02.R"

rm(list = ls())
options(scipen = 3, digits = 4, stringsAsFactors = FALSE)
#source("~/mybiotools/r/myfunc.R")

library(PDdream)
library(caret)
library(pROC) # plot the ROC curves
library(kernlab)
library(xgboost)
library(glmnet)

#method.weight = list("svm" = 8, "rf" = 7, "nnet" = 7, "nb" = 7);
#pred_outd = "Prediction_results"
test_pred_outd = "Independent_test"
validation_pred_outd = "Validation_test"
training_pred_outd = "Training_test"
ml.algorithm = c("svmRadial")
outdir = "FS_02out" #model dir
pdf.file.size = c(8,8)
caretEnsemble.prob.case = F #for caretEnsemble prediction prob, IF T, more prob, more possible case, F oppsite
validation_rdata = NULL

if (file.exists("./feature_selection_para.R"))
	source("./feature_selection_para.R", echo=T)


#threads <= 30
#CPUnum = ifelse (CPUnum <= 30, CPUnum, 30)
CPUnum = 10
out_pred = function (X, Y, pred_outd) {

	if (!file.exists(pred_outd)) {
		dir.create(pred_outd, recursive = T)
	}

	accu_out = paste0(pred_outd, "/pred.accu.rdata")

	if (!file.exists(accu_out)) {

		#load(test_out_rdata)
		library(doParallel);
		registerDoParallel(cores = CPUnum);

		pred.accu <- vector("list", length(ml.algorithm))
		names(pred.accu) <- ml.algorithm
		all_acc = c()
		for (i in 1:length(ml.algorithm)) {
			ml.method = ml.algorithm[i]
			FS_02out = paste0(outdir, "/", ml.method)
			output.rdata = paste0(outdir, "/", ml.method, "/output_", ml.method, ".rdata")
			message (paste0("Loading ", output.rdata))
			load(output.rdata)
			accu = c()
			accu <- foreach (n=1:length(out.rdata), .combine=rbind) %dopar%
			#for (n in 1:length(out.rdata))
			{
				snpnum = names(out.rdata)[n]
				ret = c()
				model_rdata = out.rdata[[n]]
				if (ml.method != "caretEnsemble") {
					out = caret_predict(X, Y, model_rdata)
					out.pred = out$predinfo$Case
					out.roc = roc(Y, out.pred, plot=F)
					out.auc = pROC::auc(out.roc)
					ret = c(out$confM$overall[c(1,2)], out$confM$byClass[c(1,2,5,6,11)], as.numeric(out.auc))
				} else {
				#	X.df = data.frame(X, check.names=T)
					require(caretEnsemble)
				#	out = predict(model_rdata, newdata=X.df, type="prob")
					out = predict(model_rdata, newdata=as.matrix(X), type="prob")
					if (caretEnsemble.prob.case) {
						pred = ifelse((out < 0.5), levels(Y)[1], levels(Y)[2])
					} else {
						pred = ifelse((out > 0.5), levels(Y)[1], levels(Y)[2])
					}
					pred = factor(pred, levels=c("Cont", "Case"))
					pred = relevel(pred,ref=2)
					confM = confusionMatrix(pred, Y)
					out.rev = 1 - out
					out.roc = roc(Y, out.rev, plot=F)
					out.auc = pROC::auc(out.roc)
					ret = c(confM$overall[c(1,2)], confM$byClass[c(1,2,5,6,11)], as.numeric(out.auc))
				}
				return (ret)
			}
			colnames(accu) = c("Accuracy", "Kappa", "Sensitivity", "Specificity", "Precision", "Recall", "Balanced Accuracy", "AUC")
			all_acc = cbind(all_acc, accu[,1])
			rownames(accu) = names(out.rdata)
			pred.accu[[ml.method]] = accu
		}

		colnames(all_acc) = ml.algorithm
		save (pred.accu, file=accu_out)
	} else {
		load(accu_out)
	}
	#output xls format
	pred.accu.out = do.call(rbind, pred.accu)
	#pred.accu.out = cbind(Features=rownames(pred.accu.out), data.frame(pred.accu.out))
	pred.accu.out = cbind(Method=rep(names(pred.accu), each=nrow(pred.accu[[1]])) ,Features=rep(rownames(pred.accu[[1]]), length(pred.accu)), data.frame(pred.accu.out))
	tab_out = paste0(pred_outd, "/pred_results.xls")
	w.table(pred.accu.out, tab_out, T)

	######
	#require(Rmisc)
	dat.n = ncol(pred.accu.out) - 2
	plot.names = c("Accuracy", "Sensitivity", "Specificity", "AUC")
	dat.n = length(plot.names)
	dat = data.frame(
					 Method = rep(pred.accu.out$Method, dat.n),
					 Features = rep(pred.accu.out$Features, dat.n),
					 Measures = rep(plot.names, each = nrow(pred.accu.out)), 
					 Values = as.vector(unlist(pred.accu.out[, plot.names]))
					 )
	pdff = paste0(pred_outd, "/", "prediction_results.pdf")

	require(lattice)
	methods.num = length(table(dat$Method))
	library(RColorBrewer)
	mycols <- brewer.pal(9, "Set1")[1:length(table(dat$Measures))]

	#trellis.device(new = FALSE, theme = col.whitebg())
	p1=dotplot(
			reorder(Features, Values) ~ Values | Method,
			data = dat,
			groups = Measures,
			#col = mycols,
			#type = "p",
			auto.key = list(
							space = "top",
							column = dat.n,
							cex = 0.5,
							title = "",
							cex.title = 1,
							lines = F,
							points = T
							),
			layout = c(methods.num, 1),
			xlab = "Prediction performance",
			strip = T
			)
	pdf(pdff, family="ArialMT", pdf.file.size[1], pdf.file.size[2])
	print (p1)
	#dotplot(Features ~ Accuracy, Sensitivity, Specificity, AUC, data=pred.accu.out)
	dev.off()
	plot_accu_v2(pred.accu, pred_outd = pred_outd)
}

pred_outd = test_pred_outd
load(test_out_rdata)
out_pred(X, Y, test_pred_outd) #for independent test
if (!is.null(validation_rdata)) {
	load(validation_rdata)
	out_pred(X, Y, validation_pred_outd) #for validation set test
}
load(train_out_rdata)
Y = as.factor(train.dat$response)
X = train.dat[, -ncol(train.dat)]
levels(Y) = c("Cont", "Case")
out_pred(X, Y, training_pred_outd) #for training set test
