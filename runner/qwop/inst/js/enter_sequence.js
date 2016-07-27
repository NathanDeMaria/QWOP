function keyEvent(k, down) {
  var event = document.createEvent("Events");
  event.initEvent(down ? "keydown" : "keyup", true, true);
  event.keyCode = k;
  event.which = k;
  document.dispatchEvent(event);
}

function hitButtons(keySequence, time) {
  var keyGroup = keySequence.pop();
  for(var i = 0; i < keyGroup.downs.length; i++) {
    keyEvent(keyGroup.downs[i], true);
  }
  for(var j = 0; j < keyGroup.ups.length; j++) {
    keyEvent(keyGroup.ups[j], false);
  }
  setTimeout(function() {
    if(keySequence.length > 0) {
      hitButtons(keySequence, time);
    }
  }, time);
}

function enterSequence(keySequence, time) {
  keyEvent(82, true);
  keyEvent(82, false);
  keyEvent(81, false);
  keyEvent(87, false);
  keyEvent(79, false);
  keyEvent(80, false);
  hitButtons(keySequence, time);
}

window.enterSequence = enterSequence;
