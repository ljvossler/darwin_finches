library(dplyr)
library(ggplot2)
library(optparse)

# Define options
option_list = list(
  make_option(c("-d", "--directory"), type="character",
              help="Should be the directory path containing your desired populations to plot. If plotting a single run, this should be the directory just above your population folders. If plotting replicate runs, this should be the directory containing all those replicate folders"),
  make_option(c("-p", "--popcode"), type="character",
              help="Population Code"),
  make_option(c("-t", "--title"), type="character",
              help="Plot Title"),
  make_option(c("-c", "--color"), type="character",
              help="Line Color")
);
# Parse options
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

out_path_pre = paste0(c(opt$directory, '/', opt$popcode, '_pre/', opt$popcode, '_pre_GONE2_Ne'), collapse = '')
out_path_post = paste0(c(opt$directory, '/', opt$popcode, '_post/', opt$popcode, '_post_GONE2_Ne'), collapse = '')
title = opt$title
pop_color = opt$color

print(out_path_post)
print(out_path_pre)

df_pre <- read.csv(out_path_pre, sep = '\t')
df_post <- read.csv(out_path_post, sep = '\t')

df_pre <- df_pre %>% mutate(time='Pre-Philornis') # Add time info
df_post <- df_post %>% mutate(time='Post-Philornis')

df_full <- rbind(df_pre, df_post) # Combine for data for comparing Ne estimates between time-separated populations
df_full <- df_full %>%
  filter(Generation <=200) # Apply whatever data filters you want. GONE is only good up to 200 generations

#color_codes <- c(pre='black', post='red')
color_codes <- c('Pre-Philornis'='gray41', 'Post-Philornis'=pop_color)

plot <- df_full %>%
  ggplot(aes(x=Generation, y=Ne_diploids, color = time)) +
  geom_point() +
  scale_color_manual(values = color_codes, name='Time') #+coord_cartesian(ylim = c(0,20))

plot_fname = paste(c(opt$directory, '/', opt$popcode, '_gone_plot.pdf'), collapse = '')
ggsave(filename = plot_fname, plot = plot, device = 'pdf', width = 8, height = 5)

print_parts = c('Saved ', opt$popcode, ' gone plot in ', opt$directory, '/', opt$popcode)
print(paste(print_parts, collapse = ''))