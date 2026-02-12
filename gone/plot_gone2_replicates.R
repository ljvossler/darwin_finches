library(dplyr)
library(ggplot2)
library(plotly)

out_file_dir = '/home/logan/Documents/Work/graduate/research/finches/darwin_finches/gone/replicates_subsampled/for'

# State output file paths and plot attributes
out_files_pre = list.files(paste0(out_file_dir, '/pre'), full.names = T)
out_files_post = list.files(paste0(out_file_dir, '/post'), , full.names = T)

title = 'Effective Population Size rec_rate 3.1 (for)'
#pop_color = "#A6C965" # par
#pop_color = "#FF817E" # for
#pop_color = "#4EAFAF" # cra
pop_color = 'orange' # testing

# Function to read in and format output files into dfs
read_df <- function(fpath, time_period) {
  df <- read.csv(fpath, sep = '\t')
  df$rep_fname <- basename(fpath)
  df <- df %>% mutate(Population=time_period)
  return(df)
}

# Get combined pre_dfa
pre_df_lst <- lapply(out_files_pre, read_df, time_period='Pre-Philornis')
pre_dfs <- do.call(rbind, pre_df_lst)

# Get combined post_df
post_df_lst <- lapply(out_files_post, read_df, time_period='Post-Philornis')
post_dfs <- do.call(rbind, post_df_lst)



df_full <- rbind(pre_dfs, post_dfs) # Combine for data for comparing Ne estimates between time-separated populations
df_full <- df_full %>%
  filter(Generation <=200) # Apply whatever data filters you want. GONE is only good up to 200 generations

color_codes <- c('Pre-Philornis'='gray41', 'Post-Philornis'=pop_color)

plot <- df_full %>%
  ggplot(aes(x=Generation, y=Ne_diploids, color = Population, group=rep_fname, text=rep_fname)) +
  geom_line(linewidth=1) +
  scale_color_manual(values = color_codes, name='Population') +
  labs(title = title, y='Estimated Ne', x='Generations') +
  theme_bw() +
  theme(title=element_text(size=16), axis.title = element_text(size=14), legend.title = element_text(size=14))
plotly::ggplotly(plot, tooltip = "text")


