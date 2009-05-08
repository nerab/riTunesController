require 'iTunes'
itunes = ITunes.new

case itunes.PlayerState
  when ITunes::PlayerState::PLAYING
    puts "Playing #{itunes.CurrentTrack.Artist}: #{itunes.CurrentTrack.name}"
  when ITunes::PlayerState::STOPPED
    puts "Paused"
  when ITunes::PlayerState::FASTFORWARD
    puts "Fast forwarding within #{itunes.CurrentTrack.Artist}: #{itunes.CurrentTrack.name}"
  when ITunes::PlayerState::REWIND
    puts "Rewinding in #{itunes.CurrentTrack.Artist}: #{itunes.CurrentTrack.name}"
  else
    puts "Unknown player state #{@itunes.PlayerState}"
end
