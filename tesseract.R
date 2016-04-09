library(png)
library(jpeg)

png_to_jpg <- function(png_file) {
  jpg_file <- gsub('\\.png', '.jpg', png_file)
  img <- readPNG(png_file)
  writeJPEG(img, target = jpg_file)
  jpg_file
}

get_ocr <- function(png_file) {
  jpg_file <- png_to_jpg(png_file)
  
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
  # Struggles with *.2 metres
  metres <- ocr_output[3]
  metres <- gsub(' 2 metres', '.2 metres', metres)
  nums <- gsub(' metres', '', metres)
  suppressWarnings(as.numeric(nums))
}

get_score <- function(png_file, alive_factor=1.2) {
  outputs <- get_ocr(png_file)
  qwop_died <- dead(outputs)
  d <- distance(outputs)
  
  if(qwop_died) {
    d
  } else {
    d * alive_factor
  }
}
