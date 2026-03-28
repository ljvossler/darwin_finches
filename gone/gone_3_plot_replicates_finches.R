library(dplyr)
library(ggplot2)
library(optparse)
#library(plotly) You can load plotly if running locally. This library has difficultly loading in HPC environment. This can let you highlight replicate lines to see which ones are being weird or interesting.

# Define options
option_list = list(
  make_option(c("-d", "--directory"), type="character",
              help="Should be the directory path containing all those replicate folders. Assumes that replicate folders are named rep(number)"),
  make_option(c("-p", "--popcode"), type="character",
              help="Population Code"),
  make_option(c("-t", "--title"), type="character",
              help="Plot Title"),
  make_option(c("-c", "--color"), type="character",
              help="Line Color"),
  make_option(c("-n", "--num_reps"), type="character",
              help="Number of replicates you wish to plot")
);
# Parse options
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# State output file paths and plot attributes

print(opt$directory)

out_files_pre=c()
out_files_post=c()
for (i in 1:opt$num_reps) {
  out_files_pre <- append(out_files_pre, paste(c(opt$directory, '/rep', i, '/', opt$popcode, '_pre/', opt$popcode, '_pre_GONE2_Ne'), collapse = ''))
  out_files_post <- append(out_files_post, paste(c(opt$directory, '/rep', i, '/', opt$popcode, '_post/', opt$popcode, '_post_GONE2_Ne'), collapse = ''))
}

print(out_files_post)
print(out_files_pre)
#pop_color = "#A6C965" # par
#pop_color = "#FF817E" # for
#pop_color = "#4EAFAF" # cra

title = opt$title
pop_color = opt$color

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
#plotly::ggplotly(plot, tooltip = "text")

plot_fname = paste(c(opt$directory, '/', opt$popcode, '_gone_plot_replicates.pdf'), collapse = '')
ggsave(filename = plot_fname, plot = plot, device = 'pdf', width = 8, height = 5)

print_msg = c('Saved ', opt$popcode, ' replicate gone plot in ', opt$directory, '/', opt$popcode)
print(paste(print_msg, collapse = ''))
