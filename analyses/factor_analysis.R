###     -*- Coding: utf-8 -*-          ###
### Analyst Charles-Édouard Giguère   ###

require(dplyr, quietly = TRUE, warn.conflicts = FALSE)
require(ggplot2, quietly = TRUE, warn.conflicts = FALSE)
require(CUFF, quietly = TRUE, warn.conflicts = FALSE)
require(psych, quietly = TRUE, warn.conflicts = FALSE)

### Get correlation matrix.

cor.df <- read.csv("OUT1/OUT/Correlation.csv")

PANNS.IT <- sprintf("PANSS%d",1:30)

SANSSAPS.COMP.IT <- c(sprintf("SANS%d", c( 1:7, 9:12, 14:16, 18:21, 23:24)),
                      sprintf("SAPS%d", c( 1:6, 8:19, 21:24, 26:33)))

SANSSAPS.SUMM.IT <- c(sprintf("SANS%d", c( 8, 13, 17, 22, 25)),
                      sprintf("SAPS%d", c( 7, 20, 25, 34)))


cor.df <- as.matrix(cor.df)


### Analysis based on SAPS/SANS items 

eigenSANSSAPS.COMP <- eigen(cor.df[SANSSAPS.COMP.IT,SANSSAPS.COMP.IT])
plot(1:50, eigenSANSSAPS.COMP$values)
abline(lm(eigenSANSSAPS.COMP$values[10:50] ~ I(10:50)),
       lty = 2)
abline(h = mean(eigenSANSSAPS.COMP$values), lty = 3)
grid()

### The original scale has 9 subscales, while the decomposition gives 14 subscales 

PC1 <- principal(cor.df[SANSSAPS.COMP.IT,SANSSAPS.COMP.IT],
          n = 14, n.obs = 205, rotate = "oblimin")


### Analysis based on SANS/SAPS & PANSS items

eigenSANSSAPSPANSS.COMP <- eigen(cor.df[c(SANSSAPS.COMP.IT,PANNS.IT),
                                        c(SANSSAPS.COMP.IT,PANNS.IT)])
plot(1:80,eigenSANSSAPSPANSS.COMP$values)
abline(lm(eigenSANSSAPSPANSS.COMP$values[10:80] ~ I(10:80)),
       lty = 2)
abline(h = mean(eigenSANSSAPSPANSS.COMP$values), lty = 3)
grid()

PC2 <- principal(cor.df[c(SANSSAPS.COMP.IT,PANNS.IT),
                 c(SANSSAPS.COMP.IT,PANNS.IT)],
          n = 15, n.obs = 205, rotate = "oblimin")


eigenNEG <-
  eigen(cor.df[c(sprintf("SANS%d", c(8,13,17,22,25)),sprintf("PANSS%d",8:14)),
               c(sprintf("SANS%d", c(8,13,17,22,25)),sprintf("PANSS%d",8:14))])
plot(1:12,eigenNEG$values, ylab = "Eigen values (negative symptoms)", xlab = "Number of components",
     type = "b")
abline(lm(eigenNEG$values[8:12] ~ I(8:12)),
       lty = 2)
abline(h = 1, lty = 3)
grid()

eigenPOS <-
  eigen(cor.df[c(sprintf("SAPS%d", c(7,20,25,34)),sprintf("PANSS%d",1:7)),
               c(sprintf("SAPS%d", c(7,20,25,34)),sprintf("PANSS%d",1:7))])
plot(1:11,eigenPOS$values, ylab = "Eigen values (positive symptoms)", xlab = "Number of components",
     type = "b")
abline(lm(eigenPOS$values[4:9] ~ I(4:9)),
       lty = 2)
abline(h = 1, lty = 3)
grid()



PCNEG4 <- principal(cor.df[c(sprintf("SANS%d", c(8,13,17,22,25)),sprintf("PANSS%d",8:14)),
                        c(sprintf("SANS%d", c(8,13,17,22,25)),sprintf("PANSS%d",8:14))],
                   nfactors = 4, n.obs = 205, rotate = "oblimin")
PCNEG4

PCNEG3 <- principal(cor.df[c(sprintf("SANS%d", c(8,13,17,22,25)),sprintf("PANSS%d",8:14)),
                        c(sprintf("SANS%d", c(8,13,17,22,25)),sprintf("PANSS%d",8:14))],
                   nfactors = 3, n.obs = 205, rotate = "oblimin")
PCNEG3

PCPOS3 <- principal(cor.df[c(sprintf("SAPS%d", c(7,20,25,34)),sprintf("PANSS%d",1:7)),
                           c(sprintf("SAPS%d", c(7,20,25,34)),sprintf("PANSS%d",1:7))],
                    nfactors = 3, n.obs = 205, rotate = "oblimin")

PCPOS3

PCPOS4 <- principal(cor.df[c(sprintf("SAPS%d", c(7,20,25,34)),sprintf("PANSS%d",1:7)),
                           c(sprintf("SAPS%d", c(7,20,25,34)),sprintf("PANSS%d",1:7))],
                   nfactors = 4, n.obs = 205, rotate = "oblimin")

PCPOS4


eigenPOSNEG <- eigen(cor.df[c(SANSSAPS.SUMM.IT,PANNS.IT[1:14]),
                            c(SANSSAPS.SUMM.IT,PANNS.IT[1:14])])

plot(1:23, eigenPOSNEG$values)

PCPOSNEG <- principal(cor.df[c(SANSSAPS.SUMM.IT,PANNS.IT[1:14]),
                             c(SANSSAPS.SUMM.IT,PANNS.IT[1:14])],
                      nfactors = 6, n.obs = 205, rotate = "oblimin")

PCPOSNEG5 <- principal(cor.df[c(SANSSAPS.SUMM.IT,PANNS.IT[1:14]),
                             c(SANSSAPS.SUMM.IT,PANNS.IT[1:14])],
                      nfactors = 5, n.obs = 205, rotate = "oblimin")


PCPOSNEG5VM <- principal(cor.df[c(SANSSAPS.SUMM.IT,PANNS.IT[1:14]),
                             c(SANSSAPS.SUMM.IT,PANNS.IT[1:14])],
                      nfactors = 5, n.obs = 205, rotate = "varimax")


loadings(PCPOSNEG) %>%
  write.table(sep = "\t")

loadings(PCPOSNEG5) %>%
  write.table(sep = "\t")


scree(PCPOSNEG)
