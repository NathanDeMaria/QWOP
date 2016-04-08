library(httr)

source('config/config.R', local = T)
master_root <- get_config('master_url')

get_task <- function() {
  task_url <- sprintf('%s/new_task', master_root)
  response <- content(GET(task_url))
  list(id = response$id, sequence = do.call(rbind, response$sequence))
}

finish_task <- function(task_id, score) {
  finish_url <- sprintf('%s/finish_task', master_root)
  json_body <- sprintf('{"task_id": "%s", "score": %f}', task_id, score)
  response <- POST(finish_url,
                   add_headers('Content-Type'='application/json'),
                   body = json_body)
  response$status_code == 200
}
