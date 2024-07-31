setwd("...")
data <- read.csv("deworming.csv")
head(data)

# No. of observations per pupil
length(data$pupid) / length(unique(data$pupid))

# Percentage of male pupils: sex: 1=male; 0=female
mean(data$sex, na.rm = TRUE)

# Percentage of pupils took the deworming pill in 1998 
mean(data$pill98, na.rm = TRUE)

# Percentage of pupils took the deworming pill in 1998 & 1999 among assigned school 1998
mean(data$pill98 [data$treat_sch98 == 1], na.rm = TRUE)
mean(data$pill99 [data$treat_sch98 == 1], na.rm = TRUE)

# Percentage of pupils who took the deworming pill in assigned school 1998 and non-girl age above 13
mean(data [data$treat_sch98 == 1 & data$old_girl98 == 0, "pill98"], na.rm = TRUE)

# Health outcome within treated school in 1998
mean(data [data$treat_sch98 == 1 & data$old_girl98 == 0 & data$pill98 == 1, "infect_early99"], na.rm = TRUE)
mean(data [data$treat_sch98 == 1 & data$old_girl98 == 0 & data$pill98 == 0, "infect_early99"], na.rm = TRUE)

# Create a subset using non-girl age above 13 only
data2 <- subset(data, old_girl98 == 0)

# School participation rate comparison between pupils with and without deworming 
# by calculating the difference in terms of outcome
mean(data2 [data2$pill98 == 1, "totpar98"], na.rm = TRUE) - mean(data2[data2$pill98 == 0, "totpar98"], na.rm = TRUE)
# by using regression
summary(fit1 <- lm(totpar98 ~ pill98, data2))

# School participation rate comparison between treated and non-treated schools
# by calculating the difference in terms of outcome
mean(data2 [data2$treat_sch98 == 1, "totpar98"], na.rm = TRUE) - mean(data2[data2$treat_sch98 == 0, "totpar98"], na.rm = TRUE)
# by using regression
summary(fit2 <- lm(totpar98 ~ treat_sch98, data2))

# Deworming percentage comparison between treated and non-treated schools
# by calculating the difference in terms of outcome
mean(data2 [data2$treat_sch98 == 1, "pill98"], na.rm = TRUE) - mean(data2 [data2$treat_sch98 == 0, "pill98"], na.rm = TRUE)
# by using regression
summary(fit3 <- lm(pill98 ~ treat_sch98, data2))
