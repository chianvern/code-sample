# Schooling and labor market consequences of school construction in Indonesia: Evidence from an unusual policy experiment

rm(list = ls())

setwd ("...")
data <- read.csv("inpres.csv")
head(data)

# Regression of log monthly earnings on education
summary(lm(log_wage ~ education, data))

# Generate a dummy variable based on age group: 0 if born 1968 or later, 1 if born before 1968
data$age_group <- data$birth_year >= 68

# Estimate the impact of the program on educational attainment using difference in differences
# Calculate the average education level for each group
E1 <- mean(data [data$high_intensity == 0 & data$age_group == FALSE, "education"])
B1 <- mean(data [data$high_intensity == 0 & data$age_group == TRUE, "education"])
D1 <- mean(data [data$high_intensity == 1 & data$age_group == FALSE, "education"])
A1 <- mean(data [data$high_intensity == 1 & data$age_group == TRUE, "education"])
G1 <- A1 - D1
H1 <- B1 - E1
C1 <- A1 - B1
F1 <- D1 - E1 
I1 <- G1 - H1

# Calculate the average wages for each group
E2 <- mean(data [data$high_intensity == 0 & data$age_group == 0, "log_wage"])
B2 <- mean(data [data$high_intensity == 0 & data$age_group == 1, "log_wage"])
D2 <- mean(data [data$high_intensity == 1 & data$age_group == 0, "log_wage"])
A2 <- mean(data [data$high_intensity == 1 & data$age_group == 1, "log_wage"])
G2 <- A2 - D2
H2 <- B2 - E2
C2 <- A2 - B2
F2 <- D2 - E2 
I2 <- G2 - H2

library(AER)

# Wald estimate of effect of education on log earnings using DiD
summary(fit2 <- lm(education ~ age_group + high_intensity + age_group*high_intensity, data))
summary(fit3 <- lm(log_wage ~ age_group + high_intensity + age_group*high_intensity, data))
fit3$coefficients[4] / fit2$coefficients[4]

# Wald estimate using IVreg. Instrument = high_intensity*age group
# Add high_intensity and age_group as controls
summary(iv1 <- ivreg(log_wage ~ education + high_intensity + age_group |
                       high_intensity*age_group + high_intensity + age_group, data))

# Wald estimate by using num_schools*age_group as instruments
# Add birth-year and regions fixed effects dummies and number of children on year 71*age_group as controls
data$instrument <- data$num_schools*data$age_group
iv2 <- ivreg(log_wage ~ education + factor(birth_year) + factor(birth_region) + age_group*children71 |
               num_schools*age_group + factor(birth_year) + factor(birth_region) + age_group*children71, data)
ivsummary <-summary(iv2)
ivsummary$coefficients[2, 1]
ivsummary$coefficients[2, 4]
