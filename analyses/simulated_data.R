###     -*- Coding: utf-8 -*-          ###
### Analyst Charles-Édouard Giguère   ###

require(dplyr, quietly = TRUE, warn.conflicts = FALSE)
require(ggplot2, quietly = TRUE, warn.conflicts = FALSE)
require(CUFF, quietly = TRUE, warn.conflicts = FALSE)
require(openxlsx, quietly = TRUE, warn.conflicts = FALSE)


Cor.df <- read.table("OUT1/OUT/Correlation.csv", sep = ",") %>%
  as.matrix


wb1 <- loadWorkbook("./phase3_panss_saps_sans.xlsx")
items <- read.xlsx(wb1, 1)


### Generate simulated data (5% missing values) for 200 subjects.

### Correspondence between original naming and item numbers
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

### Read table as data.frame.
correspondance.item <- read.table(text = correspondance_item.str,
                                  sep = "\t")

names(items)[-1] <- correspondance.item[match(names(items)[-1],
                                          correspondance.item[,1]),2]

### initialisation of random seed
set.seed(10348)
R <- Cor.df[names(items)[-1], names(items)[-1]]

X <- mvtnorm::rmvnorm(200, sigma = R)

PANSS_CUTOFF <- qnorm(seq(1/7, to = 1/7*6, by = 1/7))
SANSSAPS_CUTOFF <- qnorm(seq(1/6, to = 1/6*5, by = 1/6))

X[,1:30] <- sapply(X[,1:30], FUN = function(x) (1:7)[cut(x, c(-Inf,PANSS_CUTOFF,Inf))])
X[,-(1:30)] <- sapply(X[,-(1:30)], FUN = function(x) (0:5)[cut(x, c(-Inf,SANSSAPS_CUTOFF,Inf))])

items[1:200, 1] <- sprintf("ID%03d",1:200)
items[, -1] <- X
names(items)[-1] <- correspondance.item[match(names(items)[-1],
                                              correspondance.item[,2]),1]

write.xlsx(items,file = "./phase3_panss_saps_sans_3.xlsx")

