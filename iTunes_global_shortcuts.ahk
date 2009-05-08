^!+0::
rate(0)
return

^!+1::
rate(1)
return

^!+2::
rate(2)
return

^!+3::
rate(3)
return

^!+4::
rate(4)
return

^!+5::
rate(5)
return

^!+Space::
itunes("PlayPause", "Toggle Play / Pause")
return

^!+Up::
itunes("vol_up", "Volume up")
return

^!+Down::
itunes("vol_down", "Volume down")
return

^!+Left::
itunes("toggle_rewind", "Rewind")
return

^!+Right::
itunes("toggle_fast_forward", "Fast Forward")
return

^!+N::
itunes("crossfade_to_next", "Crossfading to next track")
return

^!+P::
itunes("crossfade_to_previous", "Crossfading to previous track")
return

^!+B::
itunes("NextTrack", "Skipping to next track")
return

^!+O::
itunes("PreviousTrack", "Skipping to previous track")
return

^!+T::
itunes("toggle_visualizer", "Toggle Visualizer")
return

rate(r)
{
  itunes("rate_and_fade", "Setting rating to " . r . " stars", r * 20)
}

;
; Invokes a command on iTunes
;
itunes(cmd, msg, arg0 = "")
{
  Run, rubyw iTunes_cmd.rb %cmd% %arg0%

  #Persistent
  TrayTip, iTunes Control, %msg%, 20, 17 ; info, no sound
  SetTimer, RemoveTrayTip, 5000
}

RemoveTrayTip:
SetTimer, RemoveTrayTip, Off
TrayTip
return
