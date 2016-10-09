/**
* Sets up a worker thread to listen for messages and send back messages processed
* by supplied function.
*
* @param performEff function to execute monad computation returned by processMessage
* @param processMessage function that takes message and returns monadic computation of response
*/
exports.initWorker = function(performEff) {
  return function (processMessage) {
    return function() {
      self.onmessage = function(e) {
        console.log('[JavaScript - worker] Message received:', e.data);
        var eff = processMessage(e.data),
            response = performEff(eff);

        console.log('[JavaScript - worker] Sending message:', response);
        postMessage(response);
      };
    };

  };
};
