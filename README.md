# QWOP

Using a genetic algorithm to evolve a good qwopper.

# Run
## Master
To run the master (takes care of generations math), run `python master/app.py`

## Slave
From the directory containing `docker-compose.xml`, run `docker-compose up -d --force-recreate --build`. This will start two docker containers - a Selenium server running Firefox, and an R container running a listener that gets tasks from the QWOP master, plays a round of QWOP, grabs the score using Tesseract OCR, and sends it back.
