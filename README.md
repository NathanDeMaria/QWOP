# QWOP

Using a genetic algorithm to evolve a good qwopper.

## Dependencies

- Tesseract
 - Download Windows `.exe` installer [here](https://github.com/UB-Mannheim/tesseract/wiki)
 - Add to PATH
- Selenium
 - Download `chromedriver` from [here](http://chromedriver.storage.googleapis.com/index.html?path=2.21/)
 - Add to PATH

## Running
Just run `main.R` and don't resize the window and it'll do magic.  Ideally...

## Config
Add a `config.xml` inside `config/`. Use the format from `sample_config.xml`. 
- `master_url` should be set to the url for your `master/app.py`

## Master
To run the master (takes care of generations math), run `python master/app.py`
