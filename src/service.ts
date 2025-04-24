import TrackPlayer, { Event } from 'react-native-track-player';

// Basic service handler - This will need to be expanded based on desired features
// (e.g., handling remote controls, notifications, etc.)
module.exports = async function() {

  TrackPlayer.addEventListener(Event.RemotePlay, () => TrackPlayer.play());

  TrackPlayer.addEventListener(Event.RemotePause, () => TrackPlayer.pause());

  TrackPlayer.addEventListener(Event.RemoteStop, () => TrackPlayer.reset());

  // Add more event listeners as needed
  // e.g., Event.RemoteNext, Event.RemotePrevious, Event.PlaybackQueueEnded

}; 