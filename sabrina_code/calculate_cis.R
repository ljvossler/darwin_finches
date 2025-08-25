# calculate CIs

# set the path for the bootstrap files and list the files in the directory
dir_path <- "~/Desktop/new_msmc_outputs/ci/for/for_post_boots/"
file_list <- list.files(path = dir_path, full.names = TRUE)

# Read all files into a list of data frames
df_list <- lapply(file_list, read.table, header = T)

# Name each element of the list after the file name (without extension)
names(df_list) <- tools::file_path_sans_ext(basename(file_list))


# Use sapply to work over the df_list, and for each item in df_list,
# grab the column in it called lambda. sapply returns something "simplified"
lambda_summary <- sapply(df_list, function(x) x$lambda) %>%
                  as.data.frame %>%
                  mutate(time_index = df_list[[1]]$time_index)


# Calculate the mean and se for each row (i.e. time point)
lambda_summary$se <- apply(lambda_summary, 1, function(x) sd(x)/sqrt(length(x)))
lambda_summary$mean <- apply(lambda_summary, 1, function(x) mean(x))

# Calculate the upper and lower ci based on the mean and se
lambda_summary <- lambda_summary %>% mutate(lowerci = mean - 1.96*se,
                                            upperci = mean + 1.96*se)


# apparently a t.test will also give us a 95% ci?
t.test(lambda_summary[1,])

# calculate the mean using the t.test method
lambda_summary$t_test_mean <- apply(lambda_summary, 1, function(x) t.test(x)$estimate)

# test if our calculated mean lines up with the t.test mean
lambda_summary$t_test_mean == lambda_summary$mean #basically the same

lambda_summary$t_test_lwr <- apply(lambda_summary, 1, function(x) t.test(x)$conf.int[[1]])
lambda_summary$t_test_upr <- apply(lambda_summary, 1, function(x) t.test(x)$conf.int[[2]])

# check how similar the cis are
plot(lowerci ~ t_test_lwr, data = lambda_summary) # very similar


# Write out results
lambda_summary %>%
  select(time_index, mean, lowerci, upperci, t_test_lwr, t_test_upr) %>%
  write.csv(., "~/Desktop/new_msmc_outputs/ci/for/for_post_lambda.csv", row.names =F)


# The for loop method, let's not use this one.
# # Create a dataframe to save the lambdas from each bootstrap iteration.
# # Create an index column (time_index) that we can use to merge it with
# # other data frames.
# lambda_summary <- data.frame(time_index = df_list[[1]]$time_index)


# for (j in 1:length(df_list)) {
#   lambda_summary[,j + 1] <- df_list[[j]]$lambda
#   colnames(lambda_summary)[j + 1] <- names(df_list[j])
# }


