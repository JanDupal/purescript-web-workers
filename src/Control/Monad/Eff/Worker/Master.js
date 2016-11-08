var webworkify = require('webworkify');

/**
* Starts a WebWorker from module "Worker"
*/
exports.startWorker = function() {
  // TODO remove hard-coded module name
  return webworkify(require("Echo"));
};

/**
* Sends message to worker.
*
* @param worker
* @param message
*/
exports.sendMessage = function(worker) {
  return function (message) {
    return function () {
      console.log("[JavaScript - master] Sending message:", message);
      worker.postMessage(message);
    }
  }
};

/**
* Sets up a parent thread to listen for messages from worker
*
* @param unsafePerformEff function to execute monad computation returned by processMessage
* @param worker
* @param cb function that takes message and returns monadic computation of response
*/
exports._onMessage = function (unsafePerformEff) {
  return function(worker) {
    return function (cb) {
      return function () {
        worker.onmessage = function (e) {
          console.log("[JavaScript - master] Message received:", e.data);
          unsafePerformEff(cb(e.data));
        };
      }
    }
  }
};
