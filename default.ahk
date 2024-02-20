#Requires AutoHotkey v2.0

F5::SoundSetVolume "+10"
F4::SoundSetVolume "-10"
F3::{
  IsMuted := SoundGetMute()
  if IsMuted
    SoundSetMute false
  else
    SoundSetMute true
}