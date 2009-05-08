require "iTunes.rb"

class MyITunesEventHandler
  # fired when a track begins playing
  def on_play(track)
    puts "Now playing '#{track.name}' by #{track.artist}"
  end
end

it = ITunes.new
it.register(MyITunesEventHandler.new)

it.start_message_loop
