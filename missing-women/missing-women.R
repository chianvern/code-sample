# Missing Women and the Price of Tea in China: The Effect of Sex-Specific Earnings on Sex Imbalance
# http://piketty.pse.ens.fr/files/Qian2008.pdf

rm(list = ls())

setwd("...")
data <- read.csv("tea.csv")
head(data)

# Generate variable teaDum, which takes value 1 if any amount of tea is sown and 0 otherwise. 
data$teaDum <- as.numeric(data$teasown > 0)

# Generate variable post, which takes a value of 1 if the cohort is born on or after 1979.
data$post <- as.numeric(data$biryr > 1978)
summary(data)

# DiD estimate for effect of reform on share of men
summary(fit1 <- lm(sex ~ teaDum + post + teaDum*post, data))

# Generate variables orchardDum and cashcropDum 
data$orchardDum <- as.numeric(data$orch > 0)
data$cashcropDum <- as.numeric(data$cashcrop > 0)

# Generate estimate for effect of reform on share of men for different crops
summary(fit2 <- lm(sex ~ teaDum + orchardDum + cashcropDum + 
                teaDum*post + orchardDum*post + cashcropDum*post + post, data))

# Generate estimate by adding dummies for county (admin) and birth-cohort (biryr)
# Use felm command in R instead of defining the vector of dummies
library(lfe)
summary(fit3 <- felm(sex ~ teaDum*post + orchardDum*post + cashcropDum*post | admin + biryr, data))
