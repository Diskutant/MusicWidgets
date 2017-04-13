#!/bin/bash

#SOXPATH="/usr/local/bin/sox";
FFMPEGPATH="/usr/local/bin/ffmpeg";
WIDGET="MusicWidgets.widget";
#TMPFILE="/tmp/widgetTrack"; 	##sox doesn't like special characters in the path
LOGFILE="$WIDGET/log.txt";
TRACKINFOFILE="$WIDGET/trackinfo.json"; ##file which is read by the javaScript to display track title etc.
ALBUMPATH=$(pwd)/$WIDGET/albumart.jpg;
DEBUG=true;
TRACKINFO="";

function log {
	if $DEBUG; then
		echo "$(date) $1" >>  "$LOGFILE";
	fi
}


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
	log "hasTrackChanged";
	if [ -e $TRACKINFOFILE ] && [ "$(cat $TRACKINFOFILE)" == "$TRACKINFO" ]; then
		return 1; #track did not change
	fi
	return 0;
}


function spectrogram {
	log "spectrogram $1";
	
	if [ ! -e "$FFMPEGPATH" ]; then
		return;
	fi
	
	log "spectrogram createSpectrogram";
	"$FFMPEGPATH" -y -i "$1" -lavfi showspectrumpic=s=ntsc:mode=separate $WIDGET/spectrogram.jpg 2>/dev/null;
}


function hasiTunesArtwork {
	log "hasiTunesArtwork";
	
	hasartwork=$(osascript -e "tell application \"iTunes\"
					try
						set artKind to kind of artwork 1 of current track
						return \"true\"
					on error e
						return \"false\"
					end try
				   end tell");
		   
	if [ "$hasartwork" == "true" ]; then
		return 0;
	else
		return 1;
	fi
}


function getiTunesArtwork {
	log "getiTunesArtwork";
		
	rm -f "$ALBUMPATH";		
	
	if ! hasiTunesArtwork; then
		return 0;
	fi

	if  hasiTunesArtwork; then
		log "getiTunesArtwork createAlbumArt";
		osascript -e "tell application \"iTunes\"
				set ct to open for access \"$ALBUMPATH\" with write permission
				set cd to data of artwork 1 of current track
				write cd to ct
				close access ct
			end tell";	
	fi
}


function getVoxArtwork {
	log "getVoxArtwork";
	
	rm -f "$ALBUMPATH";
	
	osascript -e "tell application \"VOX\"
					set cd to artwork image
					set ct to open for access \"$ALBUMPATH\" with write permission
					write cd to ct
					close access ct
				  end tell";
}


function iTunes {
	log "iTunes";
	
	TRACKINFO=$(osascript -e 'tell application "iTunes" to set {artistName, songName, albumName, albumYear, lyricsRaw} to {artist, name, album, year, lyrics} of current track
		return "{\"Artist\": \"" & artistName & "\", \"Album\": \"" & albumName & "\", \"Title\": \"" & songName & "\", \"Year\": \"" & albumYear & "\", \"Lyrics\": \"" & lyricsRaw & "\"}"');
	
	log "iTunes $TRACKINFO";
	
	if hasTrackChanged; then
		getiTunesArtwork;	
	
		fileClass=$(osascript -e 'tell application "iTunes" to return class of current track');
		if [ "$fileClass" == "file track" ]; then
			trackURL=$(osascript -e 'tell application "iTunes" to return location of current track as text');
			trackPATH="${trackURL//\://}"; ##replace ':' with '/'
			trackPATH="/Volumes/$trackPATH";
	
			#sox "$trackPATH";
			spectrogram "$trackPATH";
		else
			#rm -f "$TMPFILE"*;
			rm -f "$WIDGET/spectrogram.jpg";
		fi
		echo $TRACKINFO > "$TRACKINFOFILE"; ##that file is read by the javaScript to display the info	
	fi
}


function vox {
	TRACKINFO=$(osascript -e 'tell application "VOX" to set {artistName, songName, albumName} to {artist, track, album}
		return "{\"Artist\": \"" & artistName & "\", \"Album\": \"" & albumName & "\", \"Title\": \"" & songName & "\", \"Year\": \"" & "\"}"');

	getVoxArtwork;

	echo "VOX $TRACKINFO";
	
	trackURL=$(osascript -e 'tell application "VOX" to return trackUrl');
	trackPATH=$(urldecode $trackURL);
	trackPATH="/"${trackPATH#*/}
	
	#sox "$trackPATH";
	spectrogram "$trackPATH";
	
	echo $TRACKINFO > "$TRACKINFOFILE"; ##that file is read by the javaScript to display the info	
}


if playerState 'iTunes'; then
	iTunes;
elif playerState 'VOX'; then
	vox;
else
	rm -f "$ALBUMPATH";
	rm -f "$WIDGET/spectrogram.jpg";
	#rm -f "$TMPFILE"*;
	echo "" > "$TRACKINFOFILE";
fi

