library(ggplot2)
library(dplyr)


# Data --------------------------------------------------------------------

par_pre <- read.table("~/Desktop/new_msmc_outputs/par/msmc_output.PAR_pre_080725.final.txt", header = T)
par_ci_pre2 <- read.csv("~/Downloads/lambda.csv") # Sabrina's method of calculating lambda CIs
head(par_ci_pre)
plot(par_ci_pre$lower_ci, par_ci_pre2$t_test_lwr)

par_pre <- left_join(par_pre, par_ci_pre2)
head(par_pre)

# Calculate ne ------------------------------------------------------------
mu = 1.0e-8
gen = 4.5 # note change generation time
#ne = (1/lambda)/(2*mu)


par_pre <- par_pre %>%
  mutate(ne = (1/lambda)/(2*mu),
         upper_ne = (1/t_test_lwr)/(2*mu),
         lower_ne = (1/t_test_upr)/(2*mu),
         time_years = (left_time_boundary * gen) / mu)


head(par_pre)


# Plot --------------------------------------------------------------------

dev.off()
View(par_pre)
par_pre %>%
  #filter(time_years > 1000 & time_years < 1100000) %>%
  ggplot(aes(x = time_years, y = ne)) +
  geom_step() +
  scale_x_log10() +
  coord_cartesian(xlim = c(1000, 1100000), ylim = c(0, 125000)) +
  geom_ribbon(aes(x = time_years, ymin = lower_ne, ymax = upper_ne), alpha = .2)
