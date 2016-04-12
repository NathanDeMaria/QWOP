library(png)
library(jpeg)

get_distance_image <- function(png_file) {
  jpg_file <- gsub('\\.png', '_distance.jpg', png_file)
  img <- readPNG(png_file)
  smaller <- img[187:217 + nrow(img) - 420, 208:422 + ncol(img) - 657, 1]
  writeJPEG(smaller, target = jpg_file)
  jpg_file
}

get_upper_distance_image <- function(png_file) {
  jpg_file <- gsub('\\.png', '_upper.jpg', png_file)
  img <- readPNG(png_file)
  smaller <- img[22:53 + nrow(img) - 420, 145:492 + ncol(img) - 657, 1]
  writeJPEG(smaller, target = jpg_file)
  jpg_file
}

get_ocr <- function(jpg_file) {
  output_file <- gsub('\\.jpg', '', gsub('screenshots', 'outputs', jpg_file))
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
  
  d <- if(length(d) == 0 || is.na(d)) {
    upper_distance_jpg <- get_upper_distance_image(png_file)
    outputs <- get_ocr(upper_distance_jpg)
    distance(outputs) * alive_factor
  } else {
    d
  }
  
  file.remove(png_file)
  d
}
