#
# Simple event listener
#
require 'win32ole'

stop = false
it = WIN32OLE.new('iTunes.Application')
ev = WIN32OLE_EVENT.new(it, '_IiTunesEvents')
ev.on_event("OnPlayerStopEvent") {|track| puts "Track #{track.name} stopped" }
ev.on_event("OnPlayerPlayEvent") {|track| puts "Now playing: '#{track.name}' by #{track.artist} #{'* ' * (track.rating / 20)}" }
ev.on_event("OnQuittingEvent") {stop = true}

while !stop
  WIN32OLE_EVENT.message_loop
end

puts "That's it! Bye."

