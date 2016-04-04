# Download Tesseract install from https://github.com/UB-Mannheim/tesseract/wiki
# Add to path
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


dead <- function(ocr_outputs) {
  sapply(ocr_outputs, function(ocr_output) {
    cleaned <- gsub(' ', '', ocr_output)
    any(grepl('PARTICIPANT', cleaned))
  })
}

distance <- function(ocr_outputs) {
  # Struggles with *.2 metres
  metres <- sapply(ocr_outputs, function(x) {x[3]})
  metres <- gsub(' 2 metres', '.2 metres', metres)
  nums <- gsub(' metres', '', metres)
  suppressWarnings(as.numeric(nums))
}





# distance <- function(ocr_outputs) {
#   l <- sapply(ocr_outputs, function(x) {x[1]})
#   
#   # Sometimes it recognizes this at the beginning for some reason
#   l <- gsub('E W 4', '', l)
#   
#   metres <- gsub('[^[\\-0-9\\.a-z]]*', '', l)
#   m <- regexpr('[\\-0-9\\.]*metres', metres)
#   just_metres <- regmatches(metres, m)
#   num <- gsub('metres', '', just_metres)
#   as.numeric(num)
# }
