library(png)
library(jpeg)

get_distance_image <- function(png_file) {
  jpg_file <- gsub('\\.png', '_distance.jpg', png_file)
  img <- readPNG(png_file)
  smaller <- img[187:217, 208:422, 1]
  writeJPEG(smaller, target = jpg_file)
  jpg_file
}

get_upper_distance_image <- function(png_file) {
  jpg_file <- gsub('\\.png', '_upper.jpg', png_file)
  img <- readPNG(png_file)
  smaller <- img[22:53, 145:492, 1]
  writeJPEG(smaller, target = jpg_file)
  jpg_file
}

get_ocr <- function(jpg_file) {
  output_file <- gsub('\\.jpg', '', gsub('screenshots', 'outputs', jpg_file))
  command <- sprintf('tesseract %s %s', jpg_file, output_file)
  shell(command)
  readLines(sprintf('%s.txt', output_file))
}

dead <- function(ocr_output) {
  cleaned <- gsub(' ', '', ocr_output)
  any(grepl('PARTICIPANT', cleaned))
}

distance <- function(ocr_output) {
  if(length(ocr_output) == 0) {
    return(NA)
  }
  metres <- ocr_output[grepl('-?[0-9]+\\.?[0-9]* metres', ocr_output)]
  nums <- gsub(' metres', '', metres)
  suppressWarnings(as.numeric(nums))
}

get_score <- function(png_file, alive_factor=1.2) {
  distance_jpg <- get_distance_image(png_file)
  outputs <- get_ocr(distance_jpg)
  d <- distance(outputs)
  
  if(is.na(d)) {
    upper_distance_jpg <- get_upper_distance_image(png_file)
    outputs <- get_ocr(upper_distance_jpg)
    distance(outputs) * alive_factor
  } else {
    d
  }
}
