source('qwop.R')
source('tesseract.R')
source('slave.R')

driver <- start_qwop()

iterations <- 1e4

for(i in seq_len(iterations)) {
  task <- get_task()
  if(is.null(task[['message']])) {
    cat(sprintf("Running task %d (%s)\n", i, task$id))
    png_file <- run_sequence(driver, task$sequence)
    score <- get_score(png_file)
    success <- finish_task(task$id, score)
    if(!success) {
      stop("Error submitting finished task")
    }  
  } else {
    cat(task[['message']])
    Sys.sleep(5)
  }
}

kill(driver)
