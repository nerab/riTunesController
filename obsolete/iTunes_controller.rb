#
# iTunes Control
#
# Remote control for iTunes. Main application is a custom keymapping for rating my library.
#
# The drawback is that this application needs to run in the foreground in order to receive keyboard input.
# Therefore, I created the ahk (AutoHotkey) script that defines global shortcuts, which will invoke iTunes
# commands through iTunes.rb.
#
# As a result, this file is more or less obsolete.
#
require 'iTunes'
require 'keyboard_event_listener'

class ITunesController
  def initialize
    @itunes = ITunes.new

    mappings = {
      ' ' => lambda {|e| key_space_action_performed(e)},
      '0' => lambda {|e| key_0_action_performed(e)},
      '1' => lambda {|e| key_1_action_performed(e)},
      '2' => lambda {|e| key_2_action_performed(e)},
      '3' => lambda {|e| key_3_action_performed(e)},
      '4' => lambda {|e| key_4_action_performed(e)},
      '5' => lambda {|e| key_5_action_performed(e)},
      'n' => lambda {|e| key_n_action_performed(e)},
      'p' => lambda {|e| key_p_action_performed(e)},
      'f' => lambda {|e| key_f_action_performed(e)},
      'r' => lambda {|e| key_r_action_performed(e)},
      'u' => lambda {|e| key_u_action_performed(e)},
      'd' => lambda {|e| key_d_action_performed(e)},
      'N' => lambda {|e| key_N_action_performed(e)},
      'P' => lambda {|e| key_P_action_performed(e)},
      # '' => lambda {|e| key_X_action_performed(e)},
      'q' => lambda {|e| key_q_action_performed(e)}
    }

    print_status

    @event_listener = KeyboardEventListener.new(mappings)
    @event_listener.loop # will block until @event_listener.quit is called
  end

  def print_status
    case @itunes.PlayerState
      when ITunes::PlayerState::PLAYING
        puts "Playing #{@itunes.CurrentTrack.Artist}: #{@itunes.CurrentTrack.name}"
      when ITunes::PlayerState::STOPPED
        puts "Paused"
      when ITunes::PlayerState::FASTFORWARD
        puts "Fast forwarding within #{@itunes.CurrentTrack.Artist}: #{@itunes.CurrentTrack.name}"
      when ITunes::PlayerState::REWIND
        puts "Rewinding in #{@itunes.CurrentTrack.Artist}: #{@itunes.CurrentTrack.name}"
      else
        puts "Unknown player state #{@itunes.PlayerState}"
    end
  end

private
  def key_space_action_performed(event)
    puts "Toggle Play"
    @itunes.PlayPause
    print_status
  end

  def key_0_action_performed(event)
    puts "Set rating to none"
    @itunes.CurrentTrack.rating = 0
  end

  def key_1_action_performed(event)
    puts "Set rating to 1"
    @itunes.CurrentTrack.rating = 20
    fade_into_next
  end

  def key_2_action_performed(event)
    puts "Set rating to 2"
    @itunes.CurrentTrack.rating = 40
    fade_into_next
  end

  def key_3_action_performed(event)
    puts "Set rating to 3"
    @itunes.CurrentTrack.rating = 60
    fade_into_next
  end

  def key_4_action_performed(event)
    puts "Set rating to 4"
    @itunes.CurrentTrack.rating = 80
    fade_into_next
  end

  def key_5_action_performed(event)
    puts "Set rating to 5"
    @itunes.CurrentTrack.rating = 100
    fade_into_next
  end

  def key_n_action_performed(event)
    puts "Skipping to next song"
    @itunes.NextTrack
    print_status
  end

  def key_p_action_performed(event)
    puts "Skipping to previous song"
    @itunes.PreviousTrack
    print_status
  end

  def key_f_action_performed(event)
    if ITunes::PlayerState::FASTFORWARD == @itunes.PlayerState || ITunes::PlayerState::REWIND == @itunes.PlayerState
      @itunes.Resume
    else
      @itunes.FastForward
    end
    print_status
  end

  def key_r_action_performed(event)
    if ITunes::PlayerState::FASTFORWARD == @itunes.PlayerState || ITunes::PlayerState::REWIND == @itunes.PlayerState
      @itunes.Resume
    else
      @itunes.Rewind
    end
    print_status
  end

  def key_u_action_performed(event)
    puts "Volume up"
    @itunes.SoundVolume = @itunes.SoundVolume + 5
  end

  def key_d_action_performed(event)
    puts "Volume down"
    @itunes.SoundVolume = @itunes.SoundVolume - 5
  end

  def key_N_action_performed(event)
    puts "Gracefully skip to next track"
    orig_volume = @itunes.SoundVolume
    @itunes.fade_out(1)
    @itunes.NextTrack
    sleep 0.5 # give iTunes a second to load the next song
    @itunes.fade_in(1, orig_volume)
    print_status
  end

  def key_P_action_performed(event)
    puts "Gracefully skip to previous track"
    orig_volume = @itunes.SoundVolume
    @itunes.fade_out(1)
    @itunes.PreviousTrack
    sleep 0.5 # give iTunes a second to load the next song
    @itunes.fade_in(1, orig_volume)
    print_status
  end

#  def key_X_action_performed(event)
#    puts ""
#    @itunes.
#  end

  def key_q_action_performed(event)
    puts "Quit"
    @event_listener.quit
  end

  def fade_into_next
    # Keep current track in case we loose it. May happen when
    orig_volume = @itunes.SoundVolume
    @itunes.fade_out(1)
    @itunes.NextTrack
    @itunes.Play if !@itunes.CurrentTrack

    # no tracks left?
    if !@itunes.CurrentTrack
      puts "Playlist empty"
      return
    end

    if @itunes.CurrentTrack.duration > 120
      @itunes.PlayerPosition = 60
    else
      @itunes.PlayerPosition = @itunes.CurrentTrack.duration / 3
    end

    @itunes.fade_in(1, orig_volume)
  end

  def fade_into_previous
    orig_volume = @itunes.SoundVolume
    @itunes.fade_out(1)
    @itunes.PreviousTrack

    if @itunes.CurrentTrack.duration > 120
      @itunes.PlayerPosition = 60
    else
      @itunes.PlayerPosition = @itunes.CurrentTrack.duration / 3
    end

    @itunes.fade_in(1, orig_volume)
  end
end
