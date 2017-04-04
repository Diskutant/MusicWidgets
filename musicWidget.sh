

function isRunning {
	if pgrep -xq "$1"; then
		return 0;
	else
		return 1;
	fi
}


if isRunning 'iTunes'; then
	echo "iTunes running";
	osaScript MusicWidgets.widget/iTunesScript.scpt
	artist=$(sed '1q;d' currentTrack.txt)
	song=$(sed '2q;d' currentTrack.txt)
	album=$(sed '3q;d' currentTrack.txt)
	filepath=$(sed '4q;d' currentTrack.txt)
	
	if [ "$filepath" == ""];
	then
		rm spectrogram.png
	else
		sox $filepath -n spectrogram
	fi
	
	echo $artist;
else
	echo "iTunes not running";
fi



if [ "$S1" != "$S2" ];
then
	echo "S1('$S1') is equal to S2('$S2')"
fi