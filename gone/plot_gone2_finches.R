library(dplyr)
library(ggplot2)

out_path_pre = 'array_outputs/par_ped_test2_gone2_GONE2_Ne'
#out_path_pre = 'array_outputs/gone_run4/cra_pre/gone_output/cra_pre_GONE2_Ne'
out_path_post = 'array_outputs/par_vcf_test_gone2_GONE2_Ne'
title = 'PAR Effective Population Size'
pop_color = "#A6C965" # par
#pop_color = "#FF817E" # for
#pop_color = "#4EAFAF" # cra

df_pre <- read.csv(out_path_pre, sep = '\t')
df_post <- read.csv(out_path_post, sep = '\t')

df_pre <- df_pre %>% mutate(Population='Pre-Philornis') # Add time info
df_post <- df_post %>% mutate(Population='Post-Philornis')

df_full <- rbind(df_pre, df_post) # Combine for data for comparing Ne estimates between time-separated populations
df_full <- df_full %>%
  filter(Generation <=200) # Apply whatever data filters you want. GONE is only good up to 200 generations

color_codes <- c('Pre-Philornis'='gray41', 'Post-Philornis'=pop_color)

df_full %>%
  ggplot(aes(x=Generation, y=Ne_diploids, color = Population)) +
  geom_line(linewidth=1.5) +
  scale_color_manual(values = color_codes, name='Population') +
  labs(title = title, y='Estimated Ne', x='Generations') +
  theme_bw() +
  theme(title=element_text(size=16), axis.title = element_text(size=14), legend.title = element_text(size=14))

