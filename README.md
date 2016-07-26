# QWOP

Using a genetic algorithm to evolve a good qwopper.

# Run

## Local
###  Master
Grab the docker container from [here](https://hub.docker.com/r/nathandemaria/qwop_master/) via `docker pull nathandemaria/qwop_master` or build your own with `docker build master/.`

Run with `docker run -d nathandemaria/qwop_master`, or your own tag :)

### Slave
From the directory containing `docker-compose.xml`, run `docker-compose up -d --force-recreate`. This will start two docker containers - a Selenium server running Firefox, and an R container running a listener that gets tasks from the QWOP master, plays a round of QWOP, grabs the score using Tesseract OCR, and sends it back.  Look [here](https://hub.docker.com/r/nathandemaria/qwop_slaver/) for the definition of the R listener.

## AWS

### Master
I used the `amzn-ami-2016.03.e-amazon-ecs-optimized` image, with a `t2.micro` instance. Run the master docker container with `docker run -d -p 5000:5000 nathandemaria/qwop_master`, and use the `Public IP` as `QWOP_MASTER_ROOT` in the slave step. Make sure to open up port `5000`, at least to the slave auto scaling group created below.

### Slave
Create an ECS cluster, service, and task for QWOP. Thanks to [Micah Hausler's container-transform](https://github.com/micahhausler/container-transform) docker container for translating my `docker-compose.yaml` to AWS's JSON format. See `ecs-task.json` for an example config (don't forget to replace `<QWOP_MASTER_ROOT>`). I attached an auto scaling group using the ECS optimized AMI (`amzn-ami-2016.03.e-amazon-ecs-optimized`), on `t2.small` instances.
