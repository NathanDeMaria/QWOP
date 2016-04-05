library(RSelenium)
library(uuid)

start_qwop <- function() {
  startServer()
  
  driver <- remoteDriver(browserName = "chrome")
  driver$open()
  driver$navigate('http://www.foddy.net/Athletics.html?webgl=true')
  driver$setWindowSize(400, 520)
  
  # Give page load some time
  Sys.sleep(10)
  
  driver$executeScript("
    var canvas = document.getElementById('window1');
    var down = document.createEvent('MouseEvents');
    down.initEvent('mousedown', true, true);
    down.synthetic = true;
    canvas.dispatchEvent(down, true);
    
    var up = document.createEvent('MouseEvents');
    up.initEvent('mouseup', true, true);
    up.synthetic = true;
    canvas.dispatchEvent(up, true);
  ")

  driver$executeScript('
    function keyEvent(k, up) {
      var event = document.createEvent("Events");
      event.initEvent(up ? "keyup" : "keydown", true, true);
      event.keyCode = k;
      event.which = k;
      document.dispatchEvent(event);  
    }
    
    function hitButtons(keySequence, time) {
      var keyGroup = keySequence.pop();
      for(var i = 0; i < keyGroup.downs.length; i++) {
        keyEvent(keyGroup.downs[i], false);
      }
      for(var i = 0; i < keyGroup.ups.length; i++) {
        keyEvent(keyGroup.ups[i], true);
      }
      setTimeout(function() {
        if(keySequence.length > 0) {
          hitButtons(keySequence, time)
        }
      }, time)
    }
    
    function enterSequence(keySequence, time=100) {
      keyEvent(82, true);
      keyEvent(82, false);
      keyEvent(81, false);
      keyEvent(87, false);
      keyEvent(79, false);
      keyEvent(80, false);
      hitButtons(keySequence, time);
    }
    window.enterSequence = enterSequence;
  ')
  driver  
}

kill <- function(driver) {
  driver$closeall()
  driver$closeServer()
}

translate_vector <- function(qwop, down) {
  # Take a vector of length 4 and turn it into to the keyCodes for QWOP
  keys <- c(81, 87, 79, 90)
  unlist(sapply(seq_along(qwop), function(i) {
    if(qwop[i] == ifelse(down, 1, -1)) {
      keys[i]
    }
  }))
}

run_sequence <- function(driver, sequence) {
  # Flip the sequence
  sequence <- sequence[rev(seq_len(dim(sequence)[1])), , drop=F]
  second_arrays <- apply(sequence, 1, function(r) {
    downs <- translate_vector(r, T)
    ups <- translate_vector(r, F)
    down_list <- paste('[', paste(downs, collapse = ', '), ']')
    up_list <- paste('[', paste(ups, collapse = ', '), ']')
    sprintf('{downs:%s, ups:%s}', down_list, up_list)
  })
  script <- sprintf('enterSequence([%s], 100);', paste(second_arrays, collapse = ', '))
  driver$executeScript(script)
  
  # Wait for the sequence to run compeletely
  Sys.sleep(0.1 * nrow(sequence) + 2)
  filename <- sprintf('screenshots/%s.png', UUIDgenerate())
  driver$screenshot(file = filename)
  filename
}
