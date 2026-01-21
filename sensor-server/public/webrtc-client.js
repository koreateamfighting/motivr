const video = document.createElement('video');
video.autoplay = true;
video.controls = true;
video.muted = true;
document.body.appendChild(video);

const wsUrl = location.origin.replace(/^http/, 'ws') + '/api/stream';
const pc = new RTCPeerConnection();

pc.ontrack = (event) => {
  video.srcObject = event.streams[0];
};

const ws = new WebSocket(wsUrl);

ws.onmessage = async (msg) => {
  let data;
  try {
    data = JSON.parse(msg.data);
  } catch (e) {
    console.warn('🔍 비JSON 메시지 무시됨:', msg.data);
    return;
  }

  if (data.answer) {
    await pc.setRemoteDescription(data.answer);
  } else if (data.candidate) {
    await pc.addIceCandidate(data.candidate);
  }
};

pc.onicecandidate = ({ candidate }) => {
  if (candidate) ws.send(JSON.stringify({ candidate }));
};

ws.onopen = async () => {
  const offer = await pc.createOffer();
  await pc.setLocalDescription(offer);
  ws.send(JSON.stringify({ offer }));
};
