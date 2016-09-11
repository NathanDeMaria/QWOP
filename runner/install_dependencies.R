setwd('/root/runner/')

library(devtools)
package_loc <- 'qwop/'
install.packages('RSelenium')
install_deps(package_loc)
install.packages(package_loc, repos = NULL, type = 'source')
