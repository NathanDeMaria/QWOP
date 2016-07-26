var canvas = document.getElementById('window1');
var down = document.createEvent('MouseEvents');
down.initEvent('mousedown', true, true);
down.synthetic = true;
canvas.dispatchEvent(down, true);

var up = document.createEvent('MouseEvents');
up.initEvent('mouseup', true, true);
up.synthetic = true;
canvas.dispatchEvent(up, true);
