#' Get a task from the QWOP task master
#'
#' \code{get_task} Sends HTTP GET to the task manager, gets and parses the task's JSON
#'
#' @param master_root Root url of the QWOP task master
#'  See source on GitHub for master instructions
#' @return list(id, sequence)
#'
#' @export
get_task <- function(master_root) {
  task_url <- sprintf('%s/new_task', master_root)
  response <- content(GET(task_url))
  if(!is.null(response[['message']])) {
    return(response)
  }
  list(id = response$id, sequence = do.call(rbind, response$sequence))
}

#' Send result back to QWOP task master
#'
#' \code{finish_task} Sends HTTP POST back to task master, with the score for a completed task
#'
#' @param master_root Root url of the QWOP task master
#' @param task_id ID of the completed task
#' @param score Score on the task
#' @return success (bool)
#'
#' @export
finish_task <- function(master_root, task_id, score) {
  finish_url <- sprintf('%s/finish_task', master_root)
  json_body <- if(is.na(score)) {
    sprintf('{"task_id": "%s", "score": "NA"}', task_id)
  } else {
    sprintf('{"task_id": "%s", "score": %f}', task_id, score)
  }

  response <- POST(finish_url,
                   add_headers('Content-Type'='application/json'),
                   body = json_body)
  response$status_code == 200
}
