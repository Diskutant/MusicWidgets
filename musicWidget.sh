#!/bin/bash
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
					
function parseTrackInfo {
	osascript MusicWidgets.widget/iTunesScript.scpt
	artist=$(sed '1q;d' currentTrack.txt)
	song=$(sed '2q;d' currentTrack.txt)
	album=$(sed '3q;d' currentTrack.txt)
	filepath=$(sed '4q;d' currentTrack.txt)

	if [ "$filepath" == "" ];
	then
		rm spectrogram.png
	else
		echo 'sox';
		echo $filepath;
		##sox $filepath -n spectrogram
	fi

	echo $artist;
}

function urldecode {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}



if playerState 'iTunes'; then
	echo "iTunes running";
elif playerState 'VOX'; then
	echo "Vox running";
	trackURL=$(osascript -e 'tell application "VOX" to return trackUrl');
	trackPATH=$(urldecode $trackURL);
	trackPATH="/"${trackPATH#*/}
	ln -fs "$trackPATH" /tmp/widgetTrack
	/usr/local/bin/sox /tmp/widgetTrack -n spectrogram -o MusicWidgets.widget/spectrogram.png; ##sox doesn't like special characters in the path
else echo "wtf";
fi

