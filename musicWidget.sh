#!/bin/bash

SOXPATH="/usr/local/bin/sox";
WIDGET="MusicWidgets.widget";
TMPFILE="/tmp/widgetTrack"; 	##sox doesn't like special characters in the path
LOGFILE="$WIDGET/log.txt";
TRACKINFOFILE="$WIDGET/trackinfo.json"; ##file which is read by the javaScript to display track title etc.
ALBUMPATH=$(pwd)/$WIDGET/albumart.jpg;


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
	fi
	return 1;
}


function playerStateTranslate {
	if [ "$1" == 1 ] || [ "$1" == "playing" ]; then
		return 0;
	fi
	return 1;
}


function urldecode {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


function hasTrackChanged {
	#echo "$(date) hasChanged $1" >>  "$LOGFILE";
	SUFFIX=${1: -5};
	
	if [ -e "$TMPFILE$SUFFIX" ]; then
		lastCheck=$(ls -l "$TMPFILE$SUFFIX");
		rm -f "$TMPFILE"*;
	else
		lastCheck="";	
	fi
	
	ln -fs "$1" "$TMPFILE$SUFFIX"

	currentCheck=$(ls -l "$TMPFILE$SUFFIX");	##check if track changed
	if [ "$lastCheck" != "$currentCheck" ]; then
		#echo "true-" $1 -Last- $lastCheck -Current- $currentCheck >> "$LOGFILE";
		return 1;
	else
		#echo "false-" $1 -Last- $lastCheck -Current- $currentCheck >> "$LOGFILE";
		return 0;
	fi
}


function sox {
	#echo "$(date) sox $1" >>  "$LOGFILE";
	if [ ! -e "$SOXPATH" ]; then
		return;
	fi
	
	if ! hasTrackChanged "$1"; then
		return;
	fi

	SUFFIX=${1: -5};
	FILEINFO="$(file $TMPFILE$SUFFIX)";
	##sox doesn't support AAC
	if [ -e "$TMPFILE$SUFFIX" ] && [[ "$FILEINFO" == *"AAC"* ]]; then
		rm -f "$WIDGET/spectrogram.png";
	else
		"$SOXPATH" "$TMPFILE$SUFFIX" -n spectrogram -r -o "$WIDGET/spectrogram.png";
	fi
}


function hasiTunesArtwork {
	hasartwork=$(osascript -e "tell application \"iTunes\"
					try
						set artKind to kind of artwork 1 of current track
						return \"true\"
					on error e
						return \"false\"
					end try
				   end tell");
		   
	echo $hasartwork;	   
	if [ "$hasartwork" == "true" ]; then
		return 0;
	else
		return 1;
	fi
}


function getiTunesArtwork {
	if [ "$(cat $TRACKINFOFILE)" == "$trackInfo" ]; then
		return 0;
	fi
		
	rm -f "$ALBUMPATH";		
	
	if ! hasiTunesArtwork; then
		return 0;
	fi

	if  hasiTunesArtwork; then
		#echo "$(date) createAlbumArt" >> "$LOGFILE";
		osascript -e "tell application \"iTunes\"
				set ct to open for access \"$ALBUMPATH\" with write permission
				set cd to data of artwork 1 of current track
				write cd to ct
				close access ct
			end tell";	
	fi
}


function getVoxArtwork {
	echo "$(date) getVoxArtwork - $(cat $TRACKINFOFILE) - $trackInfo" >>  "$LOGFILE";
	if [ "$(cat $TRACKINFOFILE)" == "$trackInfo" ]; then
		return 0;
	fi
	
	rm -f "$ALBUMPATH";
	
	echo "$(date) getVoxArtwork2" >>  "$LOGFILE";
	
	osascript -e "tell application \"VOX\"
					set cd to artwork image
					set ct to open for access \"$ALBUMPATH\" with write permission
					write cd to ct
					close access ct
				  end tell";
}


function iTunes {
#	trackInfo=$(osascript -e 'tell application "iTunes" to set {artistName, songName, albumName, albumYear, lyricsRaw} to {artist, name, album, year, lyrics} of current track
#		return "{\"Artist\": \"" & artistName & "\", \"Album\": \"" & albumName & "\", \"Title\": \"" & songName & "\", \"Year\": \"" & albumYear & "\", \"Lyrics\": \"" & lyricsRaw & "\"}"');

	hasArtwork=$(hasiTunesArtwork);

#	echo $hasArtwork > "$LOGFILE";

	trackInfo=$(osascript -e 'tell application "iTunes" to set {artistName, songName, albumName, albumYear, lyricsRaw} to {artist, name, album, year, lyrics} of current track
		return "{\"Artist\": \"" & artistName & "\", \"Album\": \"" & albumName & "\", \"Title\": \"" & songName & "\", \"Year\": \"" & albumYear & "\", \"Lyrics\": \"" & lyricsRaw & "\", \"hasArtwork\": \"" & '$hasArtwork' & "\"}"');

	getiTunesArtwork;

	echo $trackInfo > "$LOGFILE";
	echo $trackInfo > "$TRACKINFOFILE"; ##that file is read by the javaScript to display the info	
	
	fileClass=$(osascript -e 'tell application "iTunes" to return class of current track');
	if [ "$fileClass" == "file track" ]; then
		trackURL=$(osascript -e 'tell application "iTunes" to return location of current track as text');
		trackPATH="${trackURL//\://}"; ##replace ':' with '/'
		trackPATH="/Volumes/"$trackPATH;
		sox "$trackPATH";
	else
		rm -f "$TMPFILE"*;
		rm -f "$WIDGET/spectrogram.png";
	fi
}


function vox {
	trackInfo=$(osascript -e 'tell application "VOX" to set {artistName, songName, albumName} to {artist, track, album}
		return "{\"Artist\": \"" & artistName & "\", \"Album\": \"" & albumName & "\", \"Title\": \"" & songName & "\", \"Year\": \"" & "\"}"');

	getVoxArtwork;

	echo $trackInfo > "$TRACKINFOFILE"; ##that file is read by the javaScript to display the info	
	
	

	trackURL=$(osascript -e 'tell application "VOX" to return trackUrl');
	trackPATH=$(urldecode $trackURL);
	trackPATH="/"${trackPATH#*/}
	sox "$trackPATH";
}


if playerState 'iTunes'; then
	iTunes;
elif playerState 'VOX'; then
	vox;
else
	rm -f "$ALBUMPATH";
	rm -f "$WIDGET/spectrogram.png";
	rm -f "$TMPFILE"*;
	echo "" > "$TRACKINFOFILE";
fi

