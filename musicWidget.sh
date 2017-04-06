#!/bin/bash

SOXPATH="/usr/local/bin/sox";
WIDGET="MusicWidgets.widget";
TMPFILE="/tmp/widgetTrack"; 	##sox doesn't like special characters in the path

function isRunning {
	if pgrep -xq "$1"; then
		return 0;
	else
		return 1;
	fi
}

function playerState {
	if isRunning $1; then
		STATE=$(osascript -e 'tell application "'$1'" to return player state');
		playerStateTranslate $STATE;
		return $?;
	else
		return 1;
	fi
}

function playerStateTranslate {
##	echo "playerTrans $1";
	if [ "$1" == 1 ] || [ "$1" == "playing" ]
	then
		return 0;
	fi
	return 1;
}

function urldecode {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


function hasTrackChanged {
	SUFFIX=${1: -5};
	
	lastCheck=$(ls -l $TMPFILE$SUFFIX);		
	
	rm -f $TMPFILE*;
	
	ln -fs "$1" $TMPFILE$SUFFIX	##sox doesn't like special characters in the path

	currentCheck=$(ls -l $TMPFILE$SUFFIX);	##check if track changed
	if [ "$lastCheck" == "$currentCheck" ]
	then
		return 1;
	else
		return 0;
	fi
}

function sox {
	if [ ! -e $SOXPATH ] 
	then
		return;
	fi
	
	if ! hasTrackChanged "$1";
	then
		return;
	fi

	SUFFIX=${1: -5};
	if [ -e $TMPFILE$SUFFIX ] && [ "$(file $TMPFILE$SUFFIX)" == *"AAC"* ]; ##sox doesn't support AAC
	then
		rm -f $WIDGET/spectrogram.png;
	else
		$SOXPATH $TMPFILE$SUFFIX -n spectrogram -r -o $WIDGET/spectrogram.png;
	fi
}


if playerState 'iTunes'; then
	trackInfo=$(osascript -e 'tell application "iTunes" to set {artistName, songName, albumName, albumYear, lyricsRaw} to {artist, name, album, year, lyrics} of current track
return "{\"Artist\": \"" & artistName & "\", \"Album\": \"" & albumName & "\", \"Title\": \"" & songName & "\", \"Year\": \"" & albumYear & "\", \"Lyrics\": \"" & lyricsRaw & "\"}"');

	echo $trackInfo; ##returns the track info in json format
	

	albumPATH=$(pwd)/$WIDGET/albumart.jpg;
	rm -f $albumPATH;
	#osascript -e "tell application \"iTunes\"
	#	set ct to open for access \"$albumPATH\" with write permission
	#		set cd to data of artwork 1 of current track
	#		write cd to ct
	#		close access ct
	#	end tell";

	
	fileClass=$(osascript -e 'tell application "iTunes" to return class of current track');
	if [ "$fileClass" == "file track" ]
	then
		trackURL=$(osascript -e 'tell application "iTunes" to return location of current track as text');
		trackPATH="${trackURL//\://}"; ##replace ':' with '/'
		trackPATH="/Volumes/"$trackPATH;
		sox "$trackPATH";
	else
		rm -f $TMPFILE*;
		rm -f $WIDGET/spectrogram.png;
	fi
elif playerState 'VOX'; then
	trackURL=$(osascript -e 'tell application "VOX" to return trackUrl');
	trackPATH=$(urldecode $trackURL);
	trackPATH="/"${trackPATH#*/}
	sox "$trackPATH";
else
	albumPATH=$(pwd)/$WIDGET/albumart.jpg;
	rm -f "$albumPATH";
	rm -f "$WIDGET/spectrogram.png";
	rm -f "$TMPFILE*";
fi

