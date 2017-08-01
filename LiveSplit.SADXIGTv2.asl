/* SADX frame counting timer. 
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
   
   
   Version 2.2 */


state("sonic")
{
	int globalFrameCount: 0x0372C6C8; //0x03B2C6C8-0x00400000 //directly tied to game speed, but freezes when pausing
	int inCutscene: 0x0372C55C;//0x03B2C55C-0x00400000
	byte gameStatus: 0x03722DE4;//0x03B22DE4-0x00400000
	byte gameMode: 0x036BDC7C; //0x03ABDC7C-0x00400000
	int inPrerenderedMovie: 0x0368B0D0;//0x03A8B0D0-0x00400000
	byte currCharacter: 0x03722DC0;//0x03B22DC0-0x00400000
	byte lastStory: 0x03718DB4; //0x03B18DB4-0x00400000 //needed to distinguish between sonic/super sonic credits
}

state("Sonic Adventure DX")
{
	int globalFrameCount: 0x0372C6C8; //0x03B2C6C8-0x00400000 //directly tied to game speed, but freezes when pausing
	int inCutscene: 0x0372C55C;//0x03B2C55C-0x00400000
	byte gameStatus: 0x03722DE4;//0x03B22DE4-0x00400000
	byte gameMode: 0x36BDC7C; //0x03ABDC7C-0x00400000
	int inPrerenderedMovie: 0x0368B0D0;//0x03A8B0D0-0x00400000
	byte currCharacter: 0x03722DC0;//0x03B22DC0-0x00400000
	byte lastStory: 0x03718DB4; //0x03B18DB4-0x00400000 //needed to distinguish between sonic/super sonic credits
}

startup
{
	vars.totalFrameCount = 0;
	vars.totalCutsceneRTA = new TimeSpan(0); //For pre-rendered cutscene rta and pausing
	vars.previousRTA = new TimeSpan(0);
	vars.creditsCounter = -1;
	refreshRate = 60;
}

start
{
	vars.totalFrameCount = 0;
	vars.totalCutsceneRTA = new TimeSpan(0); //For pre-rendered cutscene rta and pausing
	vars.previousRTA = new TimeSpan(0);
	vars.creditsCounter = -1;
}

update
{
	TimeSpan? rawRTA = timer.CurrentTime.RealTime;
	TimeSpan currentRTA = new TimeSpan(0);
	if (rawRTA.HasValue)
	{
		currentRTA = new TimeSpan(0).Add(rawRTA.Value);
	}
	
	/* Add RTA to the IGT when the frame counter
		does not increase */
	if (current.inPrerenderedMovie != 0 ||
		current.gameMode == 1 || //Splash logos
		current.gameMode == 12 || //Title + menus
		current.gameMode == 18 || //Story introduction screen
		current.gameMode == 20 || //Instruction
		current.gameStatus == 19 || //Game over screen
		current.gameStatus == 16) //Pause
	{
		vars.totalCutsceneRTA = vars.totalCutsceneRTA.Add(currentRTA-vars.previousRTA);
	}
	
	if (current.gameMode == 22) //Credits
	{
		if (old.gameMode != 22)
		{
			/* Arbitrary delay before frames are added during credits,
				so that categories that skip the credits don't get
				the frames added */
			vars.creditsCounter = 3600;
		}
		
		vars.creditsCounter -= 1;
		
		if (vars.creditsCounter == 0)
		{
			int character = current.currCharacter;
			switch (character)
			{
				case 0: 
					if (current.lastStory == 0)
						vars.totalFrameCount += 16804; //Sonic credits + emblem frame count
					else
						vars.totalFrameCount += 17360; //Super Sonic credits + emblem frame count
					break;
				case 2: vars.totalFrameCount += 14657; break;//Tails credits + emblem frame count
				case 3: vars.totalFrameCount += 16804; break;//Knuckles credits + emblem frame count
				case 5: vars.totalFrameCount += 18950; break;//Amy credits + emblem frame count
				case 6: vars.totalFrameCount += 17545; break;//Gamma credits + emblem frame count
				case 7: vars.totalFrameCount += 15333; break;//Big credits + emblem frame count
				default: break;
			}
		}
	}
	
	int deltaFrames = current.globalFrameCount - old.globalFrameCount;
	
	/* Add twice the amount of time when in a cutscene */
	if (current.inCutscene != 0)
	{
		deltaFrames*=2;
	}
	
	vars.totalFrameCount+=deltaFrames;
	
	vars.previousRTA = new TimeSpan(currentRTA.Ticks);
}

gameTime
{
	return TimeSpan.FromSeconds((vars.totalFrameCount)/60.0)+vars.totalCutsceneRTA;
}

isLoading
{
    return true;
}
