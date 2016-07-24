.get_distance_image <- function(png_file) {
  jpg_file <- gsub('\\.png', '_distance.jpg', png_file)
  img <- png::readPNG(png_file)
  smaller <- img[195:220, 250:440, 1]
  jpeg::writeJPEG(smaller, target = jpg_file)
  jpg_file
}

.get_upper_distance_image <- function(png_file) {
  jpg_file <- gsub('\\.png', '_upper.jpg', png_file)
  img <- png::readPNG(png_file)
  smaller <- img[25:60, 240:440, 1]
  jpeg::writeJPEG(smaller, target = jpg_file)
  jpg_file
}

.get_ocr <- function(jpg_file, screenshot_dir, output_dir) {
  output_file <- gsub('\\.jpg', '', gsub(screenshot_dir, output_dir, jpg_file))
  command <- sprintf('tesseract %s %s', jpg_file, output_file)
  if(exists('shell')) {
    shell(command)
  } else {
    system(command)
  }

  txt_file <- sprintf('%s.txt', output_file)
  lines <- readLines(txt_file)
  file.remove(txt_file, jpg_file)
  lines
}

.dead <- function(ocr_output) {
  cleaned <- gsub(' ', '', ocr_output)
  any(grepl('PARTICIPANT', cleaned))
}

.distance <- function(ocr_output) {
  if(length(ocr_output) == 0) {
    return(NA)
  }
  metres <- ocr_output[grepl('-?[0-9]+\\.?[0-9]* metres', ocr_output)]
  nums <- gsub(' metres', '', metres)
  suppressWarnings(as.numeric(nums))
}

#' Parse a score with Tesseract OCR
#'
#' \code{get_score} Uses Tesseract OCR to find the score from a snapshot.
#'  Assumes that you have tesseract installed and in the PATH
#'
#' @param png_file Path to .png image of the end of a QWOP run
#' @param screenshot_dir location of screenshot .pngs
#' @param output_dir location to save OCR outputs
#' @param alive_factor Bonus multiplier for QWOP runs that are still alive at the end
#' @return Score from a QWOP run
#'
#' @export
get_score <- function(png_file, screenshot_dir='screenshots', output_dir='outputs', alive_factor=1.2) {
  if(!dir.exists(screenshot_dir)) {
    stop(sprintf("Screenshot directory %s not found :(", screenshot_dir))
  }
  if(!dir.exists(output_dir)) {
    stop(sprintf("Output directory %s not found :(", output_dir))
  }

  distance_jpg <- .get_distance_image(png_file)
  outputs <- .get_ocr(distance_jpg, screenshot_dir = screenshot_dir, output_dir = output_dir)
  d <- .distance(outputs)

  d <- if(length(d) == 0 || is.na(d)) {
    logging::loginfo("End distance not found, using upper distance")
    upper_distance_jpg <- .get_upper_distance_image(png_file)
    outputs <- .get_ocr(upper_distance_jpg, screenshot_dir = screenshot_dir, output_dir = output_dir)
    new_d <- .distance(outputs) * alive_factor
    if(length(new_d) == 0) {
      NA
    } else {
      new_d
    }
  } else {
    logging::loginfo("Using end distance")
    d
  }

  file.remove(png_file)
  d
}
