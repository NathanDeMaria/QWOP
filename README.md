# QWOP

Using a genetic algorithm to evolve a good qwopper.

# Run

## Local
###  Master
Grab the docker container from [here](https://hub.docker.com/r/nathandemaria/qwop_master/) via `docker pull nathandemaria/qwop_master` or build your own with `docker build master/.`

Run with `docker run -d nathandemaria/qwop_master`, or your own tag :)

### Slave
From the directory containing `docker-compose.xml`, run `docker-compose up -d --force-recreate`. This will start two docker containers - a Selenium server running Firefox, and an R container running a listener that gets tasks from the QWOP master, plays a round of QWOP, grabs the score using Tesseract OCR, and sends it back.  Look [here](https://hub.docker.com/r/nathandemaria/qwop_slaver/) for the definition of the R listener.
