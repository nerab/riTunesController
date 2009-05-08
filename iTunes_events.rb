#
# Prototype interface for an ITunes event handler
#
# Anyone interested in events can implement one or more of these methods
# and register with an instance of the ITunes class like this:
#
# class MyITunesEventHandler
#   # fired when a track begins playing
#   def on_play(track)
#     puts "Now playing '#{track.name}' by #{track.artist}"
#   end
# end
#
# eh = MyITunesEventHandler.new
# it = ITunes.new
# it.register_event_handler(eh)
#
class ITunesEventHandler
  # fired when the iTunes database is changed
  def on_database_changed(deleted, changed)
  end

  # fired when a track begins playing
  def on_play(track)
  end

  # fired when a track stops playing
  def on_stop (track)
  end

  # fired when information about the currently playing track has changed
  def on_playing_track_changed(track)
  end

  # fired when calls to the iTunes COM interface will be deferred
  def on_busy(reason)
  end

  # fired when calls to the iTunes COM interface will no longer be deferred
  def on_ready
  end

  # fired when iTunes is about to quit
  def on_quitting
  end

  # fired when iTunes is about prompt the user to quit
  def on_prompting_for_quit
  end

  # fired when the sound output volume has changed
  def on_sound_volume_changed(newVolume)
  end
end