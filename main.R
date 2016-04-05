source('qwop.R')
source('tesseract.R')
source('generations.R')

initial_generation_size <- 50
survive_probability <- 2 / 3
parent_probability <- 1 / 3
mutate_probability <- .02
longer_probability <- .5
alive_factor <- .5


driver <- start_qwop()

generation_files <- list.files('memory/', full.names = T, pattern = '*.rds')

if(length(generation_files) > 0) {
  m <- regexpr('[0-9]+', generation_files)
  generation_numbers <- as.numeric(regmatches(generation_files, m))
  recent_generation <- which.max(generation_numbers)
  start_generation <- generation_numbers[recent_generation] + 1
  current_generation <- readRDS(generation_files[recent_generation])
} else {
  start_generation <- 2
  # Start from scratch
  current_generation <- lapply(seq_len(initial_generation_size), function(i) {
    matrix(sample(seq(-1, 1), size = 100, replace = T, prob = c(.2, .6, .2)), ncol = 4, byrow = T)
  })
}



for(i in seq(start_generation, length.out = 100)) {
  cat(sprintf('Generation %d\n', i))
  
  # Just in case :)
  if(length(current_generation) < initial_generation_size / 2) {
    current_generation <- c(current_generation, current_generation)
  }
  current_generation <- next_generation(current_generation)
  saveRDS(current_generation, file = sprintf('memory/generation_%04d.rds', i))
}

kill(driver)
