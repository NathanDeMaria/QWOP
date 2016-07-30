setwd('/root/runner/')

library(devtools)
package_loc <- 'qwop/'
install_deps(package_loc)
install.packages(package_loc, repos = NULL, type = 'source')
library(qwop)
library(logging)

logging::addHandler(logging::writeToConsole)
driver <- initialize_driver()

master_root <- Sys.getenv('QWOP_MASTER_ROOT')
if(master_root == '') {
  error_message <- "QWOP_MASTER_ROOT environment variable not set"
  logging::logerror(error_message)
  stop(error_message)
}

i <- 1
while(T) {
  logging::loginfo("Iteration %s", i)
  task <- get_task(master_root)
  if(!is.null(task$message)) {
    logging::logwarn("No available tasks, waiting...")
  } else {
    logging::loginfo("Received task %s", task$id)
    png_file <- run_sequence(driver, sequence = task$sequence)
    score <- get_score(png_file)
    logging::loginfo("Task %s scored %s", task$id, score)
    success <- finish_task(master_root, task$id, score)
    if(!success) {
      logging::logerror("Failed to submit task %s", task$id)
      stop("Error submitting task")
    } else {
      logging::loginfo("Submitted task %s to master", task$id)
    }
    i <- i + 1
  }
  Sys.sleep(5)
}
