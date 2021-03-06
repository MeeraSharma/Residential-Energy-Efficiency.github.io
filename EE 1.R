install.packages("xlsx")
library(xlsx)
table <- read.xlsx("EE Residential Buildings.xlsx",1)
colnames(table) <- c("Relative_Compactness", "Surface_Area", "Wall_Area", "Roof_Area", "Overall_Height", "Orientation", "Glazing_Area", "Glazing_Area_Distribution", "Heating_Load", "Cooling_Load")
View(table)
indexes <- sample(1:nrow(table), size = 0.2*nrow(table))

# Split Data into Training and Validation Datasets

validate <- table[indexes, ]
dim(validate)
train <- table[-indexes, ]
dim(train)

#Heating Load Multiple Linear Regression
Model1_HL <- lm(Heating_Load ~ Relative_Compactness+Surface_Area+Wall_Area+Roof_Area+Overall_Height+Orientation+Glazing_Area+Glazing_Area_Distribution, data = train)
summary(Model1_HL)
#Remove variables with p >0.05
Model2_HL <- lm(Heating_Load ~ Relative_Compactness+Surface_Area+Wall_Area+Overall_Height+Glazing_Area, data = train)
summary(Model2_HL)
pred_Model2_HL <- predict(Model2_HL, validate)
pred_Model2_HL
#To check the model quality
residuals_Model2_HL <- validate$Heating_Load - predict(Model2_HL, validate)
residuals_Model2_HL
MSE_Model2_HL <- (sum((residuals_Model2_HL)^2))/nrow(validate)
RMSE_Model2_HL <- sqrt(MSE_Model2_HL)
RMSE_Model2_HL 
#R-sqaured on the validate dataset
Model2_HL_Rsqaured <- 1-sum(residuals_Model2_HL^2)/sum((validate$Heating_Load-mean(validate$Heating_Load))^2)
Model2_HL_Rsqaured
# validate rsquared less than train rsquared. 
x_HL <- validate$Cooling_Load
y_HL <- predict(Model2_HL, validate)
reg_HL <- lm(y_HL ~ x_HL, data = validate)
plot(validate$Heating_Load,predict(Model2_HL, validate), xlab = "Actual Heating Load Values", ylab = "Predicted Heating Load Values",type = "p")
abline(reg_HL, col = "red")

#Cooling Load Multiple Linear Regression
Model1_CL <- lm(Cooling_Load ~ Relative_Compactness+Surface_Area+Wall_Area+Roof_Area+Overall_Height+Orientation+Glazing_Area+Glazing_Area_Distribution, data = train)
summary(Model1_CL)
#Remove variables with p >0.05
Model2_CL <- lm(Cooling_Load ~ Relative_Compactness+Surface_Area+Wall_Area+Overall_Height+Glazing_Area, data = train)
summary(Model2_CL)
pred_Model2_CL <- predict(Model2_CL, validate)
pred_Model2_CL
#To check the model quality
residuals_Model2_CL <- validate$Cooling_Load - predict(Model2_CL, validate)
residuals_Model2_CL
MSE_Model2_CL <- (sum((residuals_Model2_CL)^2))/nrow(validate)
RMSE_Model2_CL <- sqrt(MSE_Model2_CL)
RMSE_Model2_CL
#R-sqaured on the validate dataset
Model2_CL_Rsqaured <- 1-sum(residuals_Model2_CL^2)/sum((validate$Cooling_Load-mean(validate$Cooling_Load))^2)
Model2_CL_Rsqaured
x_CL <- validate$Cooling_Load
y_CL <- predict(Model2_CL, validate)
reg_CL <- lm(y_CL ~ x_CL, data = validate)
plot(validate$Cooling_Load,predict(Model2_CL, validate), xlab = "Actual Cooling Load Values", ylab = "Predicted Cooling Load Values",type = "p")
abline(reg_HL, col = "blue")

#cross validated linear regression
install.packages("DAAG")
library(DAAG)
# Heating Load
Model_HL_CV <- lm( Heating_Load ~ Relative_Compactness+Surface_Area+Wall_Area+Overall_Height+Glazing_Area, data = table)
CV_HL <- cv.lm(table, Model_HL_CV, m=6,plotit = FALSE)
dim(CV_HL)
RMSE_CV_HL <- sqrt(attr(CV_HL, "ms"))
SS_res_CV_HL <-  attr(CV_HL,"ms")*nrow(table)
SS_tot_CV_HL <- sum((table$Heating_Load - mean(table$Heating_Load))^2)
CV_HL_Rsqaured <- 1-SS_res_CV_HL/SS_tot_CV_HL
RMSE_CV_HL
x_HL <- validate$Heating_Load
y_HL <- predict(Model_HL_CV, validate)
reg_HL_CV <- lm(y_HL ~ x_HL, data = validate)
plot(validate$Heating_Load, predict(Model_HL_CV, validate), xlab = "Actual Heating Load", ylab = "Predicted Heating Load", type = "p")
abline(reg_HL_CV, col = "red")

# Cooling Load
Model_CL_CV <- lm( Cooling_Load ~ Relative_Compactness+Surface_Area+Wall_Area+Overall_Height+Glazing_Area, data = table)
CV_CL <- cv.lm(table, Model_CL_CV, m=6,plotit = FALSE)
dim(CV_CL) 
RMSE_CV_CL <- sqrt(attr(CV_CL, "ms"))
SSE_res_CV_CL <-  attr(CV_CL,"ms")*nrow(table)
SS_tot_CV_CL <- sum((table$Cooling_Load - mean(table$Cooling_Load))^2)
CV_CL_Rsqaured <- 1-SSE_res_CV_CL/SS_tot_CV_CL
RMSE_CV_CL
x_CL <- validate$Cooling_Load
y_CL <- predict(Model_CL_CV, validate)
reg_CL_CV <- lm(y_CL ~ x_CL, data = validate)
plot(validate$Cooling_Load, predict(Model_CL_CV, validate), xlab = "Actual Cooling Load", ylab = "Predicted Cooling Load", type = "p")
abline(reg_CL_CV, col = "blue")

#Principle Component Analysis

pca <- prcomp(train[, 1:8], scale. = TRUE)
summary(pca)
screeplot(pca, type = "lines", col = "blue")
var <- pca$sdev^2
propvar <- var/sum(var)
plot(propvar, xlab = "Principal Component", ylab = "Proportion of Variance Explained", ylim = c(0,1), type = "b")
plot(cumsum(propvar), xlab = "Principal Component", ylab = "Cumulative Proportion of Variance Explained", ylim = c(0,1), type = "b")

# Getting the first 5 principal components
PCs <- pca$x[,1:5]

install.packages("pls")
library(pls)

# Run principal component regression function with only the first 5 principal components

numcomp <- 5
pcr.fit_HL <- pcr(Heating_Load ~ Relative_Compactness+Surface_Area+Wall_Area+Roof_Area+Overall_Height+Orientation+Glazing_Area+Glazing_Area_Distribution, data = train, scale = TRUE, ncomp = numcomp)
summary(pcr.fit_HL)

pcr.fit_HL$scores
coef(pcr.fit_HL)

pcr.pred_HL <- predict(pcr.fit_HL, validate, ncomp = numcomp)

SStot_HL <- sum((validate$Heating_Load - mean(validate$Heating_Load))^2)

SSres.pred_HL <- sum((pcr.pred_HL - validate$Heating_Load)^2)
R2.pred_HL <- 1 - SSres.pred_HL/SStot_HL
R2.pred_HL

RMSE_pred_HL <- sqrt(SSres.pred_HL/nrow(validate))
RMSE_pred_HL

pcr.fit_CL <- pcr(Cooling_Load ~ Relative_Compactness+Surface_Area+Wall_Area+Roof_Area+Overall_Height+Orientation+Glazing_Area+Glazing_Area_Distribution, data = train, scale = TRUE, ncomp = numcomp)
summary(pcr.fit_CL)

pcr.fit_CL$scores
coef(pcr.fit_CL)

pcr.pred_CL <- predict(pcr.fit_CL, validate, ncomp = numcomp)

SStot_CL <- sum((validate$Cooling_Load - mean(validate$Cooling_Load))^2)

SSres.pred_CL <- sum((pcr.pred_CL - validate$Cooling_Load)^2)
R2.pred_CL <- 1 - SSres.pred_CL/SStot_CL
R2.pred_CL

RMSE_pred_CL <- sqrt(SSres.pred_CL/nrow(validate))
RMSE_pred_CL


#Feature Extraction

#Step-wise
HL_step <- step(Model1_HL, direction = "both")
summary(HL_step)
residuals_HL_step <- validate$Heating_Load - predict(HL_step, validate)
HL_step_Rsqaured <- 1-sum(residuals_HL_step^2)/sum((validate$Heating_Load-mean(validate$Heating_Load))^2)
HL_step_Rsqaured
MSE_HL_step <- (sum((residuals_HL_step)^2))/nrow(validate)
RMSE_HL_step <- sqrt(MSE_HL_step)
RMSE_HL_step
  
CL_step <- step(Model1_CL, direction = "both")
summary(CL_step)
residuals_CL_step <- validate$Cooling_Load - predict(CL_step, validate)
CL_step_Rsqaured <- 1-sum(residuals_CL_step^2)/sum((validate$Cooling_Load-mean(validate$Cooling_Load))^2)
CL_step_Rsqaured
MSE_CL_step <- (sum((residuals_CL_step)^2))/nrow(validate)
RMSE_CL_step <- sqrt(MSE_CL_step)
RMSE_CL_step

#Lasso Regression - Feature Extraction - Peanalized Maximum Likelihood

#Scaling the Data - except response variables
scaledTrain <- as.data.frame(scale(train[,c(1,2,3,4,5,6,7,8)]))
scaledTrain <- cbind(scaledTrain, train[,c(9,10)]) # Add response variables back in

scaledValidate <- as.data.frame(scale(validate[,c(1,2,3,4,5,6,7,8)]))
scaledValidate <- cbind(scaledValidate, validate[,c(9,10)]) # Add response variables back in

install.packages("glmnet")
library(glmnet)

lasso_HL <- cv.glmnet(x = as.matrix(scaledTrain[, c(1,2,3,4,5,6,7,8)]), y = as.vector(scaledTrain[ ,9]), alpha=1, nfolds = 10, type.measure = "mse", family = "gaussian")
coef(lasso_HL)
mod_lasso_HL <- lm(Heating_Load~Wall_Area+Overall_Height+Glazing_Area+Glazing_Area_Distribution, data = scaledTrain)
summary(mod_lasso_HL)
residuals_mod_lasso_HL <- scaledValidate$Heating_Load - predict(mod_lasso_HL, scaledValidate)
MSE_lasso_HL <- (sum(residuals_mod_lasso_HL^2)/nrow(scaledValidate))
RMSE_lasso_HL <- sqrt(MSE_lasso_HL)
RMSE_lasso_HL

lasso_CL <- cv.glmnet(x = as.matrix(scaledTable[, c(1,2,3,4,5,6,7,8)]), y = as.vector(scaledTrain[ ,10]), alpha=1, nfolds = 10, type.measure = "mse", family = "gaussian")
coef(lasso_CL)
mod_lasso_CL <- lm(Cooling_Load~Wall_Area+Overall_Height+Glazing_Area, data = scaledTrain)
summary(mod_lasso_CL)
residuals_mod_lasso_CL <- scaledValidate$Cooling_Load - predict(mod_lasso_CL, scaledValidate)
MSE_lasso_CL <- (sum(residuals_mod_lasso_CL^2)/nrow(scaledValidate))
RMSE_lasso_CL <- sqrt(MSE_lasso_CL)
RMSE_lasso_CL


#Classification and Regression Trees
# does recursive partioning

install.packages("rpart")
library(rpart)
tree.train_HL.2 <- rpart(Heating_Load ~ Relative_Compactness+Surface_Area+Wall_Area+Roof_Area+Overall_Height+Orientation+Glazing_Area+Glazing_Area_Distribution, data = train)  
summary(tree.train_HL.2)
plotcp(tree.train_HL.2)
plot(tree.train_HL.2)
text(tree.train_HL.2)
printcp(tree.train_HL.2)

#pruning using CP with the minimum error

prune.tree.train_HL.2 <- prune(tree.train_HL.2, cp = tree.train_HL.2$cptable[which.min(tree.train_HL.2$cptable[,"xerror"]),"CP"])
yhat.prune.tree.validate_HL <- predict(prune.tree.train_HL.2, newdata = validate)
SSres.prune.tree.validate_HL <- sum((yhat.prune.tree.validate_HL-validate$Heating_Load)^2)

plot(validate$Heating_Load, yhat.prune.tree.validate_HL, xlab = "Actual Heating Load", ylab = "Predicted Heating Load")
abline(0,1)

plot(validate$Heating_Load, scale(yhat.prune.tree.validate_HL - validate$Heating_Load), xlab = "Actual Heating Load", ylab = "Heating Load Error")
abline(0,0)

SStot.prune.tree.validate_HL <- sum((validate$Heating_Load - mean(validate$Heating_Load))^2)
R2.prune.tree.validate_HL <- 1 - SSres.prune.tree.validate_HL/SStot.prune.tree.validate_HL
R2.prune.tree.validate_HL
RMSE_prune.tree.validate_HL <- sqrt((SSres.prune.tree.validate_HL)/nrow(validate))
RMSE_prune.tree.validate_HL

#Cooling Load

tree.train_CL.2 <- rpart(Cooling_Load ~ Relative_Compactness+Surface_Area+Wall_Area+Roof_Area+Overall_Height+Orientation+Glazing_Area+Glazing_Area_Distribution, data = train)  
summary(tree.train_CL.2)
plotcp(tree.train_CL.2)
plot(tree.train_CL.2)
text(tree.train_CL.2)
printcp(tree.train_CL.2)

#pruning using CP with the minimum error

prune.tree.train_CL.2 <- prune(tree.train_CL.2, cp = tree.train_CL.2$cptable[which.min(tree.train_CL.2$cptable[,"xerror"]),"CP"])
yhat.prune.tree.validate_CL <- predict(prune.tree.train_CL.2, newdata = validate)
SSres.prune.tree.validate_CL <- sum((yhat.prune.tree.validate_CL-validate$Cooling_Load)^2)

plot(validate$Cooling_Load, yhat.prune.tree.validate_CL, xlab = "Actual Cooling Load", ylab = "Predicted Cooling Load")
abline(0,1)

plot(validate$Cooling_Load, scale(yhat.prune.tree.validate_CL - validate$Cooling_Load), xlab = "Actual Cooling Load", ylab = "Cooling Load Error")
abline(0,0)

SStot.prune.tree.validate_CL <- sum((validate$Cooling_Load - mean(validate$Cooling_Load))^2)
R2.prune.tree.validate_CL <- 1 - SSres.prune.tree.validate_CL/SStot.prune.tree.validate_CL
R2.prune.tree.validate_CL
RMSE_prune.tree.validate_CL <- sqrt((SSres.prune.tree.validate_CL)/nrow(validate))
RMSE_prune.tree.validate_CL

#Random Forests
install.packages("randomForest")
library(randomForest)
set.seed(1)

# Heating Load
numpred <- 3
rf.train_HL <- randomForest(Heating_Load~Relative_Compactness+Surface_Area+Wall_Area+Roof_Area+Overall_Height+Orientation+Glazing_Area+Glazing_Area_Distribution, data = train, mtry = numpred, importance = TRUE)
rf.train_HL

yhat.rf_HL <- predict(rf.train_HL, newdata = validate)
SSres_rf_HL <- sum((yhat.rf_HL-validate$Heating_Load)^2)
plot(validate$Heating_Load, yhat.rf_HL, xlab = "Actual Heating Load", ylab = "Predicted Heating Load")
abline(0,1)

plot(validate$Heating_Load, scale(yhat.rf-validate$Heating_Load), xlab = "Predicted Heating Load", ylab = "Predicted Heating Load Error")
abline(0,0)
SStot_rf_HL <- sum((validate$Heating_Load - mean(validate$Heating_Load))^2)
R2_rf_HL <- 1- SSres_rf_HL/SStot_rf_HL
R2_rf
importance(rf.train_HL)
varImpPlot(rf.train_HL)

RMSE_rf_HL <-  sqrt((SSres.pred_HL)/nrow(validate))
RMSE_rf_HL

# Cooling Load
numpred <- 3
rf.train_CL <- randomForest(Cooling_Load~Relative_Compactness+Surface_Area+Wall_Area+Roof_Area+Overall_Height+Orientation+Glazing_Area+Glazing_Area_Distribution, data = train, mtry = numpred, importance = TRUE)
rf.train_CL

yhat.rf_CL <- predict(rf.train_CL, newdata = validate)
SSres_rf_CL <- sum((yhat.rf_CL-validate$Cooling_Load)^2)
plot(validate$Cooling_Load, yhat.rf_CL, xlab = "Actual Cooling Load", ylab = "Predicted Cooling Load")
abline(0,1)

plot(validate$Cooling_Load, scale(yhat.rf_CL-validate$Heating_Load), xlab = "Predicted Cooling Load", ylab = "Predicted Cooling Load Error")
abline(0,0)
SStot_rf_CL <- sum((validate$Cooling_Load - mean(validate$Cooling_Load))^2)
R2_rf_CL <- 1- SSres_rf_CL/SStot_rf_CL
R2_rf_CL
importance(rf.train_CL)
varImpPlot(rf.train_CL)

RMSE_rf_CL <-  sqrt((SSres.pred_CL)/nrow(validate))
RMSE_rf_CL
