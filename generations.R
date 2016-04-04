evaluate_generation <- function(generation) {
  screenshots <- sapply(seq_along(generation), function(i) {
    cat(sprintf('Running: %d\n', i))
    s <- generation[[i]]
    run_sequence(driver, s)
  })
  
  outputs <- lapply(screenshots, get_ocr)
  deads <- dead(outputs)
  distances <- distance(outputs)
  
  # NOTE: not sure how to best handle this, but doing this to prefer those that don't die at the end
  distances[!deads] <- distances[!deads] + mean(distances[deads & (distances > 0)], na.rm = T) * alive_factor
  distances
}

# percentile <- function(x) {
#   probability <- rep(0, length(x))
#   probability[!is.na(x)] <- rank(x[!is.na(x)], na.last = F) / length(x[!is.na(x)])
#   probability
# }

scale_range <- function(x) {
  min_x <- min(x, na.rm = T)
  max_x <- max(x, na.rm = T)
  scaled <- (x - min_x) / max_x
  scaled[is.na(x)] <- 0
  scaled
}

to_probability <- function(x, expected_keep) {
  x * expected_keep / sum(x) * length(x)
}

make_babies <- function(parents, mutate_probability, longer_probability) {
  lapply(parents, function(parent) {
    flip <- sample(0:1, replace = T, size = length(parent), prob = c(1 - mutate_probability, mutate_probability))
    mutated <- apply(xor(parent, flip), 2, as.numeric)
    if(longer_probability > runif(1)) {
      # adds a half second, to the front because time goes the other direction :/
      mutated <- rbind(mutated, matrix(sample(0:1, replace = T, size = 20), ncol = 4))
    }
    mutated
  })
}

next_generation <- function(current_generation) {
  scores <- evaluate_generation(current_generation)
  print(scores)
  adjusted_scores <- scale_range(scores)
  
  does_survive <- to_probability(adjusted_scores, survive_probability) > runif(length(scores))
  is_parent <- to_probability(adjusted_scores, parent_probability) > runif(length(scores))
  
  babies <- make_babies(current_generation[is_parent], mutate_probability, longer_probability)
  
  c(babies, current_generation[does_survive])
}
