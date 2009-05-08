require 'win32ole'

#
# Decorator for iTunes' OLE object. This class mainly exists to add
# some convenience methods to what the iTunes API provides. It also prevents
# the OLE stuff from leaking through.
#
# Being a decorator means that all methods that are not implemented here
# are sent to the iTunes OLE object.
#
class ITunes
  class PlayerState
    STOPPED     = 0 # Player is stopped.
    PLAYING     = 1 # Player is playing.
    FASTFORWARD = 2 # Player is fast forwarding.
    REWIND      = 3 # Player is rewinding.
  end

  def initialize
    @itunes = WIN32OLE.new('iTunes.Application') # the OLE object itself

    # Delegate to the OLE object
    # from http://blog.jayfields.com/2008/02/ruby-replace-methodmissing-with-dynamic.html
    @itunes.public_methods(false).each do |meth|
      (class << self; self; end).class_eval do
        define_method meth do |*args|
          @itunes.send meth, *args
        end
      end
    end

    @listeners = [] # event handler registry
    setup_events
  end

  #
  # message loop
  #
  # This method will block until stop_message_loop is called
  #
  def start_message_loop
    @stop_message_loop = false

    while !@stop_message_loop do
      WIN32OLE_EVENT.message_loop
    end
  end

  def stop_message_loop
    @stop_message_loop = true
  end

  def register(listener)
    @listeners << listener
  end

  def unregister(listener)
    @listeners.delete(listener)
  end

  #
  # Logarithmic fade out
  #
  def fade_out(fade_time = 3, vol_from = @itunes.SoundVolume)
    vol_from.downto 1 do |i|
      @itunes.SoundVolume = log_norm(i, vol_from)
      sleep Float(fade_time) / vol_from
    end
    @itunes.SoundVolume = 0
  end

  #
  # Logarithmic fade in
  #
  def fade_in(fade_time = 3, vol_til = 100)
    1.upto vol_til do |i|
      @itunes.SoundVolume = log_norm(i, vol_til)
      sleep Float(fade_time) / vol_til
    end
  end

  def rate_and_fade(r = 0)
    @itunes.CurrentTrack.rating = r
    crossfade_to_next
  end

  def toggle_fast_forward
    if ITunes::PlayerState::FASTFORWARD == @itunes.PlayerState || ITunes::PlayerState::REWIND == @itunes.PlayerState
      @itunes.Resume
    else
      @itunes.FastForward
    end
  end

  def toggle_rewind
    if ITunes::PlayerState::FASTFORWARD == @itunes.PlayerState || ITunes::PlayerState::REWIND == @itunes.PlayerState
      @itunes.Resume
    else
      @itunes.Rewind
    end
  end

  def vol_up(v = 5)
    @itunes.SoundVolume = @itunes.SoundVolume + v
  end

  def vol_down(v = 5)
    @itunes.SoundVolume = @itunes.SoundVolume - v
  end

  def crossfade_to_next
    orig_volume = @itunes.SoundVolume
    fade_out(1)
    @itunes.NextTrack
    @itunes.Play if !@itunes.CurrentTrack

    # no tracks left?
    if !@itunes.CurrentTrack
      raise "Playlist empty"
    end

    if @itunes.CurrentTrack.duration > 120
      @itunes.PlayerPosition = 60
    else
      @itunes.PlayerPosition = @itunes.CurrentTrack.duration / 3
    end

    fade_in(1, orig_volume)
  end

  def crossfade_to_previous
    orig_volume = @itunes.SoundVolume
    fade_out(1)
    @itunes.PreviousTrack
    @itunes.Play if !@itunes.CurrentTrack

    # no tracks left?
    if !@itunes.CurrentTrack
      raise "Playlist empty"
    end

    if @itunes.CurrentTrack.duration > 120
      @itunes.PlayerPosition = 60
    else
      @itunes.PlayerPosition = @itunes.CurrentTrack.duration / 3
    end

    fade_in(1, orig_volume)
  end

  def toggle_visualizer
    @itunes.VisualsEnabled = !@itunes.VisualsEnabled
  end

private
  #
  # return log10(val), normed to norm
  #
  def log_norm(val, norm)
    retval = norm * Math.log10(Float(val) / norm * 10)
    retval < 0 ? 0 : retval
  end

  def setup_events
    ev = WIN32OLE_EVENT.new(@itunes, '_IiTunesEvents')

    ev.on_event{|*args| @listeners.each{l| l.fallback(*args)}}

    ev.on_event("OnDatabaseChangedEvent"){|deleted_ids, changed_ids|
      # resolve changed ids to objects
      changed = []
      changed_ids.each{|record|
        changed << @itunes.GetITObjectByID(record[0], record[1], record[2], record[3])
      }

      @listeners.each{|l|
        l.on_database_changed(deleted_ids, changed) if l.respond_to?(:on_database_changed)
      }
    }

    ev.on_event("OnPlayerPlayEvent"){|track|
      @listeners.each{|l|
        l.on_play(track) if l.respond_to?(:on_play)
      }
    }

    ev.on_event("OnPlayerStopEvent"){|track|
      @listeners.each{|l|
        l.on_stop(track) if l.respond_to?(:on_stop)
      }
    }

    ev.on_event("OnPlayerPlayingTrackChangedEvent"){|track|
      @listeners.each{|l|
        l.on_playing_track_changed(track) if l.respond_to?(:on_playing_track_changed)
      }
    }

    ev.on_event("OnCOMCallsDisabledEvent"){|reason|
      @listeners.each{|l|
        l.on_busy(reason) if l.respond_to?(:on_busy)
      }
    }

    ev.on_event("OnCOMCallsEnabledEvent"){
      @listeners.each{|l|
        l.on_ready if l.respond_to?(:on_ready)
      }
    }

    ev.on_event("OnAboutToPromptUserToQuitEvent"){
      @listeners.each{|l|
        l.on_prompting_for_quit if l.respond_to?(:on_prompting_for_quit)
      }
      stop_message_loop
    }

    ev.on_event("OnSoundVolumeChangedEvent"){|newVolume|
      @listeners.each{|l|
        l.on_sound_volume_changed(newVolume) if l.respond_to?(:on_sound_volume_changed)
      }
    }

    ev.on_event("OnQuittingEvent"){
      @listeners.each{|l|
        l.on_quitting if l.respond_to?(:on_quitting)
      }
      stop_message_loop
    }
  end
end
