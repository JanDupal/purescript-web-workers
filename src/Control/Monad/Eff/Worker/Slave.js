/**
* Sets up a worker thread to listen for messages
*
* @param unsafePerformEff function to execute monad computation returned by processMessage
* @param cb function that takes message and returns monadic computation of response
*/
exports._onMessage = function(unsafePerformEff) {
  return function (cb) {
    return function() {
      self.onmessage = function(e) {
        console.log('[JavaScript - worker] Message received:', e.data);
        unsafePerformEff(cb(e.data));
      };
    };
  };
};

/**
* Sends message back to parent thread
*
* @param message
*/
exports.sendMessage = function(message) {
  return function () {
    console.log("[JavaScript - worker] Sending message:", message);
    postMessage(message);
  }
};
