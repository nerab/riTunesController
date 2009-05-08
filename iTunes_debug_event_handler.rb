class ITunesDebugEventHandler
  # fired when the iTunes database is changed
  def on_database_changed(deleted, changed)
    p "Database changed. Deleted were #{deleted.inspect}."
    p "Changed were:"

    changed.each{|o|
      p "#{o.ole_obj_help.name} => #{o.name}"
    }
  end

  # fired when a track begins playing
  def on_play(track)
    p "Playing '#{track.name}' by #{track.artist}"
  end

  # fired when a track stops playing
  def on_stop (track)
    p "Stopped '#{track.name}' by #{track.artist}"
  end

  # fired when information about the currently playing track has changed
  def on_playing_track_changed(track)
    p "Track '#{track.name}' by #{track.artist} was changed"
  end

  # fired when calls to the iTunes COM interface will be deferred
  def on_busy(reason)
    p "iTunes is busy because #{reason}"
  end

  # fired when calls to the iTunes COM interface will no longer be deferred
  def on_ready
    p "iTunes is ready again"
  end

  # fired when iTunes is about to quit
  def on_quitting
    p "iTunes is about to quit"
  end

  # fired when iTunes is about prompt the user to quit
  def on_prompting_for_quit
    p "iTunes is prompting for quit"
  end

  # fired when the sound output volume has changed
  def on_sound_volume_changed(newVolume)
    p "iTunes volume changed to #{newVolume}"
  end
end
