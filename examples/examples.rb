#
# iTunes Control
#
require 'iTunes'


itunes = ITunes.new
fade_out
itunes.NextTrack

if track.length > 3.minutes
  itunes.PlayerPosition = 60
else
  itunes.PlayerPosition = track.length / 3
end

fade_in

