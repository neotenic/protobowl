var RTCPeerConnection = null;
var getUserMedia = null;
var attachMediaStream = null;
var reattachMediaStream = null;
var webrtcDetectedBrowser = null;
var webrtcDetectedVersion = null;

function trace(text) {
  // This function is used for logging.
  if (text[text.length - 1] == '\n') {
    text = text.substring(0, text.length - 1);
  }
  console.log((performance.now() / 1000).toFixed(3) + ": " + text);
}

if (navigator.mozGetUserMedia) {
  console.log("This appears to be Firefox");

  webrtcDetectedBrowser = "firefox";

  webrtcDetectedVersion =
           parseInt(navigator.userAgent.match(/Firefox\/([0-9]+)\./)[1], 10);

  // The RTCPeerConnection object.
  RTCPeerConnection = mozRTCPeerConnection;

  // The RTCSessionDescription object.
  RTCSessionDescription = mozRTCSessionDescription;

  // The RTCIceCandidate object.
  RTCIceCandidate = mozRTCIceCandidate;

  // Get UserMedia (only difference is the prefix).
  // Code from Adam Barth.
  getUserMedia = navigator.mozGetUserMedia.bind(navigator);

  // Creates iceServer from the url for FF.
  createIceServer = function(url, username, password) {
    var iceServer = null;
    var url_parts = url.split(':');
    if (url_parts[0].indexOf('stun') === 0) {
      // Create iceServer with stun url.
      iceServer = { 'url': url };
    } else if (url_parts[0].indexOf('turn') === 0) {
      if (webrtcDetectedVersion < 27) {
        // Create iceServer with turn url.
        // Ignore the transport parameter from TURN url for FF version <=27.
        var turn_url_parts = url.split("?");
        // Return null for createIceServer if transport=tcp.
        if (turn_url_parts[1].indexOf('transport=udp') === 0) {
          iceServer = { 'url': turn_url_parts[0],
                        'credential': password,
                        'username': username };
        }
      } else {
        // FF 27 and above supports transport parameters in TURN url,
        // So passing in the full url to create iceServer.
        iceServer = { 'url': url,
                      'credential': password,
                      'username': username };
      }
    }
    return iceServer;
  };

  // Attach a media stream to an element.
  attachMediaStream = function(element, stream) {
    console.log("Attaching media stream");
    element.mozSrcObject = stream;
    element.play();
  };

  reattachMediaStream = function(to, from) {
    console.log("Reattaching media stream");
    to.mozSrcObject = from.mozSrcObject;
    to.play();
  };

  // Fake get{Video,Audio}Tracks
  MediaStream.prototype.getVideoTracks = function() {
    return [];
  };

  MediaStream.prototype.getAudioTracks = function() {
    return [];
  };
} else if (navigator.webkitGetUserMedia) {
  console.log("This appears to be Chrome");

  webrtcDetectedBrowser = "chrome";
  webrtcDetectedVersion =
         parseInt(navigator.userAgent.match(/Chrom(e|ium)\/([0-9]+)\./)[2], 10);

  // Creates iceServer from the url for Chrome.
  createIceServer = function(url, username, password) {
    var iceServer = null;
    var url_parts = url.split(':');
    if (url_parts[0].indexOf('stun') === 0) {
      // Create iceServer with stun url.
      iceServer = { 'url': url };
    } else if (url_parts[0].indexOf('turn') === 0) {
      // Chrome M28 & above uses below TURN format.
      iceServer = { 'url': url,
                    'credential': password,
                    'username': username };
    }
    return iceServer;
  };

  // The RTCPeerConnection object.
  RTCPeerConnection = webkitRTCPeerConnection;

  // Get UserMedia (only difference is the prefix).
  // Code from Adam Barth.
  getUserMedia = navigator.webkitGetUserMedia.bind(navigator);

  // Attach a media stream to an element.
  attachMediaStream = function(element, stream) {
    if (typeof element.srcObject !== 'undefined') {
      element.srcObject = stream;
    } else if (typeof element.mozSrcObject !== 'undefined') {
      element.mozSrcObject = stream;
    } else if (typeof element.src !== 'undefined') {
      element.src = URL.createObjectURL(stream);
    } else {
      console.log('Error attaching stream to element.');
    }
  };

  reattachMediaStream = function(to, from) {
    to.src = from.src;
  };
} else {
  console.log("Browser does not appear to be WebRTC-capable");
}

// function maybePreferAudioSendCodec(sdp) {
//   if (audio_send_codec == '') {
//     console.log('No preference on audio send codec.');
//     return sdp;
//   }
//   console.log('Prefer audio send codec: ' + audio_send_codec);
//   return preferAudioCodec(sdp, audio_send_codec);
// }

// function maybePreferAudioReceiveCodec(sdp) {
//   if (audio_receive_codec == '') {
//     console.log('No preference on audio receive codec.');
//     return sdp;
//   }
//   console.log('Prefer audio receive codec: ' + audio_receive_codec);
//   return preferAudioCodec(sdp, audio_receive_codec);
// }

// // Set |codec| as the default audio codec if it's present.
// // The format of |codec| is 'NAME/RATE', e.g. 'opus/48000'.
// function preferAudioCodec(sdp, codec) {
//   var fields = codec.split('/');
//   if (fields.length != 2) {
//     console.log('Invalid codec setting: ' + codec);
//     return sdp;
//   }
//   var name = fields[0];
//   var rate = fields[1];
//   var sdpLines = sdp.split('\r\n');

//   // Search for m line.
//   for (var i = 0; i < sdpLines.length; i++) {
//       if (sdpLines[i].search('m=audio') !== -1) {
//         var mLineIndex = i;
//         break;
//       }
//   }
//   if (mLineIndex === null)
//     return sdp;

//   // If the codec is available, set it as the default in m line.
//   for (var i = 0; i < sdpLines.length; i++) {
//     if (sdpLines[i].search(name + '/' + rate) !== -1) {
//       var regexp = new RegExp(':(\\d+) ' + name + '\\/' + rate, 'i');
//       var payload = extractSdp(sdpLines[i], regexp);
//       if (payload)
//         sdpLines[mLineIndex] = setDefaultCodec(sdpLines[mLineIndex],
//                                                payload);
//       break;
//     }
//   }

//   // Remove CN in m line and sdp.
//   sdpLines = removeCN(sdpLines, mLineIndex);

//   sdp = sdpLines.join('\r\n');
//   return sdp;
// }

// // Set Opus in stereo if stereo is enabled.
// function addStereo(sdp) {
//   var sdpLines = sdp.split('\r\n');

//   // Find opus payload.
//   for (var i = 0; i < sdpLines.length; i++) {
//     if (sdpLines[i].search('opus/48000') !== -1) {
//       var opusPayload = extractSdp(sdpLines[i], /:(\d+) opus\/48000/i);
//       break;
//     }
//   }

//   // Find the payload in fmtp line.
//   for (var i = 0; i < sdpLines.length; i++) {
//     if (sdpLines[i].search('a=fmtp') !== -1) {
//       var payload = extractSdp(sdpLines[i], /a=fmtp:(\d+)/ );
//       if (payload === opusPayload) {
//         var fmtpLineIndex = i;
//         break;
//       }
//     }
//   }
//   // No fmtp line found.
//   if (fmtpLineIndex === null)
//     return sdp;

//   // Append stereo=1 to fmtp line.
//   sdpLines[fmtpLineIndex] = sdpLines[fmtpLineIndex].concat(' stereo=1');

//   sdp = sdpLines.join('\r\n');
//   return sdp;
// }

// function extractSdp(sdpLine, pattern) {
//   var result = sdpLine.match(pattern);
//   return (result && result.length == 2)? result[1]: null;
// }

// // Set the selected codec to the first in m line.
// function setDefaultCodec(mLine, payload) {
//   var elements = mLine.split(' ');
//   var newLine = new Array();
//   var index = 0;
//   for (var i = 0; i < elements.length; i++) {
//     if (index === 3) // Format of media starts from the fourth.
//       newLine[index++] = payload; // Put target payload to the first.
//     if (elements[i] !== payload)
//       newLine[index++] = elements[i];
//   }
//   return newLine.join(' ');
// }

// // Strip CN from sdp before CN constraints is ready.
// function removeCN(sdpLines, mLineIndex) {
//   var mLineElements = sdpLines[mLineIndex].split(' ');
//   // Scan from end for the convenience of removing an item.
//   for (var i = sdpLines.length-1; i >= 0; i--) {
//     var payload = extractSdp(sdpLines[i], /a=rtpmap:(\d+) CN\/\d+/i);
//     if (payload) {
//       var cnPos = mLineElements.indexOf(payload);
//       if (cnPos !== -1) {
//         // Remove CN payload from m line.
//         mLineElements.splice(cnPos, 1);
//       }
//       // Remove CN line in sdp
//       sdpLines.splice(i, 1);
//     }
//   }

//   sdpLines[mLineIndex] = mLineElements.join(' ');
//   return sdpLines;
// }
