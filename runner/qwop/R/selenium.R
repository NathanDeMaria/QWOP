#' QWOP Driver
#'
#' \code{initialize_driver} creates an RSelenium driver running QWOP
#'
#' @return QWOP driver
#'
#' @export
initialize_driver <- function() {
  driver <- RSelenium::remoteDriver(browserName = 'firefox', remoteServerAddr = 'selenium')
  driver$open()
  driver$navigate('http://www.foddy.net/Athletics.html?webgl=true')
  driver$setWindowSize(700, 500)

  # Give page load some time
  Sys.sleep(10)

  # Drop in the scripts we'll use
  driver$executeScript(.read_javascript('click.js'))
  driver$executeScript(.read_javascript('enter_sequence.js'))
  driver
}

.read_javascript <- function(js) {
  js_file <- system.file('js', js, package = 'qwop')
  lines <- readLines(js_file)
  paste(lines, collapse = '\n')
}

.translate_vector <- function(qwop, down) {
  # Take a vector of length 4 and turn it into to the keyCodes for QWOP
  keys <- c(81, 87, 79, 80)
  unlist(sapply(seq_along(qwop), function(i) {
    if(qwop[i] == ifelse(down, 1, -1)) {
      keys[i]
    }
  }))
}

#' Run a sequence of moves
#'
#' \code{run_sequence} Runs a sequence of moves
#'
#' @param driver QWOP driver created by \code{initialize_driver}
#' @param sequence (nx4) matrix specifying a sequence of Q, W, O, and P actions
#' @param screenshot_dir Location to save screenshots to
#' @return Path to the snapshot (.png) of the game after running the sequence
#'
#' @export
#'
run_sequence <- function(driver, sequence, screenshot_dir='screenshots') {
  # Flip the sequence
  if(!dir.exists(screenshot_dir)) {
    stop(sprintf("Screenshot directory %s not found :(", screenshot_dir))
  }
  sequence <- sequence[rev(seq_len(dim(sequence)[1])), , drop=F]
  second_arrays <- apply(sequence, 1, function(r) {
    downs <- .translate_vector(r, T)
    ups <- .translate_vector(r, F)
    down_list <- paste('[', paste(downs, collapse = ', '), ']')
    up_list <- paste('[', paste(ups, collapse = ', '), ']')
    sprintf('{downs:%s, ups:%s}', down_list, up_list)
  })
  script <- sprintf('enterSequence([%s], 100);', paste(second_arrays, collapse = ', '))
  driver$executeScript(script)

  # Wait for the sequence to run compeletely
  Sys.sleep(0.1 * nrow(sequence) + 2)
  filename <- sprintf('%s/%s.png', screenshot_dir, uuid::UUIDgenerate())
  driver$screenshot(file = filename)
  filename
}
