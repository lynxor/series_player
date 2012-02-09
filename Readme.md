# Series player

Keep track of where you are with your series!  Useful for anime where there are 600 eps in one folder and you can't remember the ep you watched last.


# Installation

	ghc seriesPlayer.hs
	mv seriesPlayer ~/bin # or somewhere on your path

	cp series /etc/bash_completion.d/ 

# Usage

To watch episode 564, just use:

	series 564

after watching 564 you will be asked if you want to watch 565. Alternatively you can come back later and continue where you left off:
	
	series --continue
