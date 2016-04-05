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
    options <- seq(-1, 1)
    
    flip <- sapply(seq_len(nrow(parent)), function(i) {
      # total probability is still ~mutate_probability, but end ones are less likely
      adjusted_probability <- (i / nrow(parent) + 0.5) * mutate_probability
      sample(0:1, replace = T, size = 4, prob = c(1 - adjusted_probability, adjusted_probability))
    })
    flip <- sample(0:1, replace = T, size = length(parent), prob = c(1 - mutate_probability, mutate_probability))
    
    # super inefficient, oh well
    mutated <- sapply(seq_along(parent), function(i) {
      if(flip[i]) {
        sample(options[options != parent[i]], size = 1)
      } else {
        parent[i]
      }
    })
    mutated <- matrix(mutated, byrow = F, ncol = 4)
    
    if(longer_probability > runif(1)) {
      # adds a half second from a random other parent
      other_parent <- sample(parents, size = 1)[[1]]
      mutated <- rbind(mutated, tail(other_parent, n = 5))
    }
    simplify_genome(mutated)
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

simplify_genome <- function(genome) {
  apply(genome, 2, function(x) {
    # I'm so sorry, it's just easier
    on <- F
    for(i in seq_along(x)) {
      if(x[i] == 1) {
        if(on) {
          x[i] <- 0
        } else {
          on <- T
        }
      } else if (x[i] == -1) {
        if(on) {
          on <- F
        } else {
          x[i] <- 0
        }
      }
    }
    x
  })
}
