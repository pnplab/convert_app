###     -*- Coding: utf-8 -*-       ###
### Analyst Charles-Édouard Giguère ###

options(stringsAsFactors = FALSE)

### Test to see if dplyr, CUFF, openxlsx, psych are installed
ip <- dimnames(installed.packages())[[1]]

if(!("dplyr" %in% ip))
    install.packages("dplyr",
                     repos = "http://cran.r-project.org")
if(!("CUFF" %in% ip))
  install.packages("CUFF", repos = "http://cran.r-project.org")

install.packages("CUFF", repos = "http://cran.r-project.org")

if(!("psych" %in% ip))
    install.packages("psych",
                     repos = "http://cran.r-project.org")


### load dplyr, CUFF, openxlsx
require(dplyr, quietly = TRUE, warn.conflicts = FALSE)
require(CUFF, quietly = TRUE, warn.conflicts = FALSE)
require(openxlsx, quietly = TRUE, warn.conflicts = FALSE)


### load function ICC from psych package.
ICC <- psych::ICC

### Take select from dplyr. Conflict because multcomp uses MASS that
### also has a select functions
select <- dplyr::select

### Pop a window to see where the data is located
Excel_file <- file.choose()

### Extract directory from Excel file
setwd(sub("[\\/][^/\\]+$", "", Excel_file))

### read Excel spread sheet
df1 <- read.xlsx(Excel_file, 1, colNames = TRUE)

### Correspondance between long names and short names indexed by number
correspondance_item.str <- 'nPANSS_ABSTRACT_THINKING	PANSS12
nPANSS_ANXIETY	PANSS16
nPANSS_ATTENTION	PANSS25
nPANSS_BLUNTED_AFFECT	PANSS8
nPANSS_CON_DIS	PANSS2
nPANSS_DELUSIONS	PANSS1
nPANSS_DEPRESSION	PANSS20
nPANSS_DISORIENTATION	PANSS24
nPANSS_EMOTIONAL_WITHDRAWAL	PANSS9
nPANSS_EXCITEMENT	PANSS4
nPANSS_GRANDIOSITY	PANSS5
nPANSS_GUILT_FEELINGS	PANSS17
nPANSS_HALLUCINATORY_BEHAVIOR	PANSS3
nPANSS_HOSTILITY	PANSS7
nPANSS_IMPULSE	PANSS28
nPANSS_JUDGMENT	PANSS26
nPANSS_MANNERISIM	PANSS19
nPANSS_MOTOR_RETARDATION	PANSS21
nPANSS_POOR_RAPPORT	PANSS10
nPANSS_PREOCCUPATION	PANSS29
nPANSS_SOCIAL_AVOIDANCE	PANSS30
nPANSS_SOMATIC_CONCERN	PANSS15
nPANSS_SPONTANEITY	PANSS13
nPANSS_STEREOTYPED_THINKING	PANSS14
nPANSS_SUSPICIOUSNESS	PANSS6
nPANSS_TENSION	PANSS18
nPANSS_UNCOOPERATIVE	PANSS22
nPANSS_UNUSUAL_THOUGHT	PANSS23
nPANSS_VOLITION	PANSS27
nPANSS_WITHDRAWAL	PANSS11
nSANS_AFFECTIVE_FLATTENING	SANS8
nSANS_AFFECTIVE_NONRESPONSE	SANS5
nSANS_ALOGIA	SANS13
nSANS_ANERGIA	SANS16
nSANS_ANHEDONIA	SANS22
nSANS_ATTENTION	SANS25
nSANS_AVOLITION	SANS17
nSANS_BLOCKING	SANS11
nSANS_EXPRESSIVE	SANS3
nSANS_EYE_CONTACT	SANS4
nSANS_FACIAL	SANS1
nSANS_HYGIENE	SANS14
nSANS_IMPERSISTENCE	SANS15
nSANS_INAPPROPRIATE_AFFECT	SANS6
nSANS_INTIMACY	SANS20
nSANS_MENTAL_TESTING	SANS24
nSANS_RECREATION	SANS18
nSANS_RELATIONSHIPS	SANS21
nSANS_RESPONSE_LATENCY	SANS12
nSANS_SEXUAL	SANS19
nSANS_SOCIAL_INATTENTIVENESS	SANS23
nSANS_SPEECH	SANS9
nSANS_SPEECH_CONTENT	SANS10
nSANS_SPONTANEOUS	SANS2
nSANS_VOCAL_INFLECTIONS	SANS7
nSAPS_AGGRESSIVE_BEHAVIOR	SAPS23
nSAPS_APPEARANCE	SAPS21
nSAPS_AUDITORY_HALLUCINATIONS	SAPS1
nSAPS_CIRCUMSTANTIALITY	SAPS30
nSAPS_CLANGING	SAPS33
nSAPS_CONTROLLED_DELUSIONS	SAPS15
nSAPS_DERAILMENT	SAPS26
nSAPS_DISTRACTIBLE_SPEECH	SAPS32
nSAPS_GLOBAL_BEHAVIOR	SAPS25
nSAPS_GLOBAL_DELUSIONS	SAPS20
nSAPS_GLOBAL_HALLUCINATIONS	SAPS7
nSAPS_GLOBAL_THOUGHT_DISORDER	SAPS34
nSAPS_GRANDIOSE_DELUSIONS	SAPS11
nSAPS_GUILT_DELUSIONS	SAPS10
nSAPS_ILLOGICALITY	SAPS29
nSAPS_INCOHERENCE	SAPS28
nSAPS_JEALOSY_DELUSIONS	SAPS9
nSAPS_MIND_READING_DELUSIONS	SAPS16
nSAPS_OLF_HALL	SAPS5
nSAPS_PERSECUTORY_DELUSIONS	SAPS8
nSAPS_PRESSURE_SPEECH	SAPS31
nSAPS_REFERENCE_DELUSIONS	SAPS14
nSAPS_RELIGIOUS_DELUSIONS	SAPS12
nSAPS_REPETITIVE_BEHAVIOR	SAPS24
nSAPS_SOCIAL_BEHAVIOR	SAPS22
nSAPS_SOMATIC_DELUSIONS	SAPS13
nSAPS_TACTILE_HALLUCINATIONS	SAPS4
nSAPS_TANGENTIALITY	SAPS27
nSAPS_THOUGHT_BROADCASTING	SAPS17
nSAPS_THOUGHT_INSERTION	SAPS18
nSAPS_THOUGHT_WITHDRAWAL	SAPS19
nSAPS_VISUAL_HALLUCINATIONS	SAPS6
nSAPS_VOICES_COMMENTING	SAPS2
nSAPS_VOICES_CONVERSING	SAPS3'

### Read correspondance table of items in a data.frame.
correspondance.item <- read.table(text = correspondance_item.str,
                                  sep = "\t")

names(df1)[-1] <- correspondance.item[match(names(df1)[-1],
                                          correspondance.item[,1]),2]


### Special function computing mean if
### 2/3 of items are non missing.

mean.p <- function(x, pval = 2/3){
    p.val <- mean(!is.na(x))
    mean(x, na.rm = (p.val >= pval))
}



### Part 1 : Compute positive and negative scores.

### (1) SANS_composite = mean(SANS items 1–7, 9–12, 14–16, 18–21, and 23–24),
df1$SANS_composite <- apply(df1[,sprintf("SANS%d", c( 1:7 ,  9:12, 14:16,
                                                     18:21, 23:24))],
                            1, mean.p)

### (2) SAPS_composite = mean(SAPS items 1–6, 8–19, 21–24, and 26–33),
df1$SAPS_composite <- apply(df1[,sprintf("SAPS%d", c( 1:6 ,  8:19,
                                                     21:24, 26:33))],
                            1, mean.p)

### (3) SANS_summary = mean(SANS items 8, 13, 17, 22, and 25),
df1$SANS_summary <- apply(df1[,sprintf("SANS%d", c( 8, 13, 17, 22, 25))],
                            1, mean.p)

### (4) SAPS_summary = mean(SAPS items 7, 20, 25, and 34),
df1$SAPS_summary <- apply(df1[,sprintf("SAPS%d", c( 7, 20, 25, 34))],
                            1, mean.p)


### (5) PANSS_positive = mean(PANSS items 1–7),
df1$PANSS_positive <- apply(df1[,sprintf("PANSS%d", 1:7)],
                                    1, mean.p)

### (6) PANSS_negative = mean(PANSS items 8–14),
df1$PANSS_negative <- apply(df1[,sprintf("PANSS%d", 8:14)],
                            1, mean.p)




### Part 2: Factors (load > 0.4) based on Factor analysis.

### (7) SANS 3 factors (F1) ITEM 8 13.
df1$SANS_neg_it8_13 <- apply(df1[, sprintf("SANS%d",c(8,13))],
                             1, mean.p)

### (8) SANS 3 factors (F2) ITEM 17 22.
df1$SANS_neg_it17_22 <- apply(df1[, sprintf("SANS%d",c(17,22))],
                             1, mean.p)

### (9) SANS 3 factors (F3) ITEM 25.
df1$SANS_neg_it25 <- df1$SANS25

### (10) PANSS (NEG) 3 factors (F1) ITEM 8, 10, 13.
df1$PANSS_neg_it8_10_13 <- apply(df1[, sprintf("PANSS%d", c(8,10,13))],
                                    1, mean.p)

### (11) PANSS (NEG) 3 factors (F2) ITEM 9, 11.
df1$PANSS_neg_it9_11 <- apply(df1[, sprintf("PANSS%d", c(9, 11))],
                              1, mean.p)

### (12) PANSS (NEG) 3 factors (F3) ITEM 12.
df1$PANSS_neg_it12 <- df1$PANSS12

### (13) SAPS 3 factors (F1) ITEM 20.
df1$SAPS_pos_it_20 <- df1$SAPS20

### (14) SAPS 3 factors (F2) ITEM 25, 34.
df1$SAPS_pos_it_25_34 <- apply(df1[, sprintf("SAPS%d", c(25, 34))],
                               1, mean.p)

### (15) SAPS 3 factors (F3) ITEM 7.
df1$SAPS_pos_it_7 <- df1$SAPS7

### (16) PANSS 3 factors (F1) ITEM 1, 5:7.
df1$PANSS_pos_it1_5_6_7 <- apply(df1[, sprintf("PANSS%d", c(1,5:7))],
                                   1, mean.p)

### (17) PANSS 3 factors (F2) ITEM 2.
df1$PANSS_pos_it2 <- df1$PANSS2



### ERREUR CODAGE 18 & 19

### (18) PANSS 3 factors (F3) ITEM 3.
df1$SAPS_pos_it_3 <- df1$SAPS3

### (19) PANSS 4 factors (F3) ITEM 3.
df1$PANSS_pos_it_3 <- df1$PANSS3




### Creation of output directories.
if(!dir.exists("./OUT"))
    dir.create("./OUT")

if(!dir.exists("./PLOT"))
    dir.create("./PLOT")

### Compute coefficients of correlation
### for all pairs of variables. The results
### are saved in a text file as correlation
### with their pvalue and also saved in a
### csv format in order to do further analyses
### on the correlation structure. 

fcor <- file("./OUT/Correlation.txt", open = "wt", encoding = "utf-8")
sink(fcor)
cat("### Compute coefficients of correlation", fill = TRUE)
cat("### for all pairs of variables.\n", fill = TRUE)
cat("> correlation(df1)\n", fill = TRUE)
correlation(df1[,-1])
sink()
sink(type = "message")
close(fcor)
write.table(cor(na.exclude(df1[,-1])),file = "OUT/Correlation.csv",sep = ",")
closeAllConnections()

### Function to compute fit indices.
fit_index <- function(x){
    ## remove row with missing values.
    x <- na.exclude(x)
    c(ICC = ICC(x)$results[3,2],
      MSE = mean((x[,1]-x[,2])^2))
}


### Function to generate a split defined by the training proportion.
generate_split <- function(prop = 0.8, N){
    ### size of subclusters.
    N1 <- round(N*prop)
    N2 <- N - N1
    ### generation of subclusters.
    sample(rep(1:2,c(N1,N2)), N)
}

### Generate 100 splits and store them in a matrix.
set.seed(1234)
split.mat <- replicate(100,generate_split(N = dim(df1)[1]))

### Function to establish a correspondance.
### y is the dependant variable in character
### x is the predictor in character
### df is the data.frame used (df1 by default).
### output_file is the file where it is sent.
### Test on these values first:
###  SANS_composite,PANSS_negative

RES.COR <- data.frame()

correspondance <- function(y, x, df = df1,
                           output_file = NULL
                           ){
  
  df <- df %>% select(x,y)
  ## Sample size.
  N <- dim(df)[1]
  ## Main model.
  fit.mat <- matrix(NA, 2, 100, dimnames = list(c("ICC","MSE"),
                                                1:100))
  form <- formula(paste(y,x, sep = " ~ "))
  for(split in 1:100){
    lm_train <- lm(form, data = df %>% filter(split.mat[,split] == 1))
    test <- df %>% filter(split.mat[,split] == 2)
    test[, paste(y,".p",sep = "")] <- predict(lm_train, test)
    ## fit indices for first split.
    fit.mat[,split] <- fit_index(test[,paste(y,c("",".p"),sep = "")])    
  }
  ## We locate the split giving the median ICC.
  med.fit <- median(fit.mat[1,])
  split.medICC <- (1:100)[order(abs(fit.mat[1,]-med.fit))][1]
  lm_train <- lm(form, data = df %>% filter(split.mat[,split.medICC] == 1))

  test <- df %>% filter(split.mat[,split.medICC] == 2)
  test[, paste(y,".p",sep = "")] <- predict(lm_train, test)
  fit_res <- apply(fit.mat, 1,
                   function(x)
                     quantile(x, c(0, 0.025, 0.5, 0.975, 1))
                   )
  dimnames(fit_res)[[1]] <- c("min(0%)", "low(2.5%)",
                              "median(50%)", "high(97.5%)",
                              "max(100%)")
  ## Output model.
  if(!is.null(output_file)){
    sink(output_file)
    cat(sprintf("Summary of the regression of %s on %s:\n", y, x))
    print(summary(lm_train))
    RES.COR <<- rbind(RES.COR, data.frame(y, x, int = lm_train$coefficients[1],
                                         slope = lm_train$coefficients[2]))
    cat(sprintf("Fit indices on the regression of %s on %s\n " %+%
                "(including  different percentile\n  " %+%
                "using 100 %.0f/%.0f random splits):\n", y, x,
                100*0.8, 100*(1 - 0.8)))
    print(fit_res)
    sink()
    sink(type = "message")
  }
  ## regresion plot.
  if(grepl("SA[PN]S", x))
    xlim <- c(0,5)
  else
    xlim <- c(1,7)
  if(grepl("SA[PN]S", y))
    ylim <- c(0,5)
  else
    ylim <- c(1,7)
  

  plotdf <- df[,c(x,y)]
  plotdf$SPLIT <- split.mat[, split.medICC]
  plotdf$w <- ave(!is.na(plotdf[,x]) & !is.na(plotdf[,y]),
                  plotdf[,x],plotdf[,y],plotdf$SPLIT, FUN = sum, na.rm = TRUE)
  plotdf <- unique(plotdf)
  plot(plotdf[,c(x,y)],pch = 19, xlim = xlim, ylim = ylim, col = plotdf$SPLIT,
       cex = sqrt(plotdf$w))
  abline(coef(lm_train),lwd = 2)
  coef.df <- data.frame(row.names = c("INT","SLOPE"))
  coef.df[,x] <- c(0,1)
  ci.test.pred <- predict(lm_train, coef.df, interval = "confidence")
  pi.test.pred <- predict(lm_train, coef.df, interval = "prediction")
  abline(c(ci.test.pred[1,2],diff(ci.test.pred[1:2,2])), lty = 3, lwd = 2)
  abline(c(ci.test.pred[1,3],diff(ci.test.pred[1:2,3])), lty = 3, lwd = 2)
  abline(c(pi.test.pred[1,2],diff(pi.test.pred[1:2,2])), lty = 2, lwd = 2)
  abline(c(pi.test.pred[1,3],diff(pi.test.pred[1:2,3])), lty = 2, lwd = 2)
}


### Scores to compare in the analyses.
compare.df <- read.table(sep = ",", header = TRUE, text = 'y,x
SANS_composite,PANSS_negative
SANS_summary,PANSS_negative
SANS_composite,SANS_summary
SAPS_composite,PANSS_positive
SAPS_summary,PANSS_positive
SAPS_composite,SAPS_summary
SANS_neg_it8_13,PANSS_neg_it8_10_13
SANS_neg_it17_22,PANSS_neg_it9_11
SANS_neg_it25,PANSS_neg_it12
SAPS_pos_it_20,PANSS_pos_it1_5_6_7
SAPS_pos_it_25_34,PANSS_pos_it2
SAPS_pos_it_7,PANSS_pos_it_3')

### Run first batch of analyses.
steps <- 12*2
step <- 0




cat("Starting Analyses: \n")
w = 0.8
## Output file.
out.res <- file(sprintf("OUT/COR%.0f-%.0f.txt",w*100,100*(1-w)),
                open = "wt", encoding = "utf-8")
## plot file.
pdf(sprintf("PLOT/COR%.0f-%.0f.pdf",100*w,100*(1-w)))
for( i in 1:dim(compare.df)[1]){
  cat("*")
  step = step + 1
  if((step %% 20) == 0 | step == steps)
    cat(sprintf(" % 5.1f %%\n", 100*step/steps))
  try(correspondance(y = compare.df[i,1],
                     x = compare.df[i,2],
                     output_file = out.res))
  cat("*")
  step = step + 1
  if((step %% 20) == 0 | step == steps)
    cat(sprintf(" % 5.1f %%\n", 100*step/steps))
  try(correspondance(x = compare.df[i,1],
                     y = compare.df[i,2],
                     output_file = out.res))
}
dev.off()
close(out.res)


write.table(RES.COR,file = "OUT/RES.COR.csv", row.names = FALSE, sep = ",")

cat("End of analyses (series 1): \n\n")









