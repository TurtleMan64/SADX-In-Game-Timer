# SADX-In-Game-Timer
Script to use with LiveSplit to get In-Game-Time from Sonic Adventure DX (2004 disc version, not Steam)

SADX frame counting timer. 
The in-game time represents the what your time
would be if there were 60 frames in a second.

Example: Say your game runs at ~62.5 fps. After 1 minute
of play, your RTA would be 1 minute, but your IGT would 
be ~ 1 minute 2.5 seconds. This means having a higher 
framerate does not give you any advantage over others
in terms of IGT.

As of now, this timer does not split for you, but that
could of course be added on by merging this code 
with the existing autosplitter.

During cutscenes, the game runs at half the framerate, 
so this timer adds double the frames when in cutscenes.

This version tracks you IGT accurately even when playing
the game at a lower display refresh rate, either from the config
editor's "Frame Rate" option set to Low or Normal, from 
options for your GPU, or just the computer being under stress.

However, the address used to track the IGT like this does not 
increase during various parts of the game, specifically during 
pausing, title screen, etc., so the IGT increases by RTA during 
these moments.

The address used to track the IGT does not increase during
credits either, but counting by RTA during credits is not 
a good idea, so instead each characters credits IGT has been
pre-calculated, and is added roughly 1 minute into their 
credits. This allows for categories that skip the credits to
not have the credits IGT added, yet also allows categories
that do watch the credits to have the IGT added.
