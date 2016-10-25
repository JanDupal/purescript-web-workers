var webworkify = require('webworkify');

/**
* Starts a WebWorker from file Worker.js and sends a message.
*
* @param messageReceived callback for messages from worker
* @param message payload to send to worker
*/
exports.startWorker = function(messageReceived) {
  return function(message) {
    return function() {
      var worker = webworkify(require("Worker"));
      worker.onmessage = function(e) {
        console.log("[JavaScript - master] Message received:", e.data);
        messageReceived(e.data)();
      };

      // Artifical delay for demo purposes
      setTimeout(function() {
        console.log("[JavaScript - master] Sending message:", message);
        worker.postMessage(message);
      }, 1000);
    }
  }
};
