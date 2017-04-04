

command: 'MusicWidgets.widget/musicWidget.sh && cat MusicWidgets.widget/currentTrack.txt'
//command: 'cat MusicWidgets.widget/currentTrack.txt'

,refreshFrequency: 100000


,render: function(output) {
  //var data = this.parseOutput(output);
  var html  = '<div id="musicWidget">';

   html += '<div id="track"></div>';
   html += '<div id="trackinfo"></div>';
   html += '<div id="lyrics"></div>';
   html += '<div id="spectrogram">test<img src="MusicWidgets.widget/spectrogram.png"/></div>';
   html += '</div>';

  html +=  '</div>';
  
  return html;
}



,update: function(output, domElement) {
	info = $(domElement).find('#trackinfo');
	//info.html(this.readTextFile("file://~/Library/Application Support/Übersicht/widgets/MusicWidgets/currentTrack.txt"));
	info.html(output);
	lyrics = $(domElement).find('#lyrics');
	lyrics.html("Lyrics");
	
}


,readTextFile: function(file)
{
    var rawFile = new XMLHttpRequest();
    rawFile.open("GET", file, false);
    rawFile.onreadystatechange = function ()
    {
        if(rawFile.readyState === 4)
        {
            if(rawFile.status === 200 || rawFile.status == 0)
            {
                var allText = rawFile.responseText;
                return allText;
            }
        }
    }
    rawFile.send(null);
    return "Fehler";
}


,style: "													\n\
	top: 20px														\n\
	left: 20px														\n\
	color: #000												\n\
															\n\
	#musicWidget											\n\
		background: rgba(#000, .5)							\n\
		top: 10px											\n\
		left: 10px											\n\
															\n\
	#track													\n\
		background: #ff0000									\n\
															\n\
	#trackinfo												\n\
		background: #00ff00									\n\
		color: #000											\n\
															\n\
	#lyrics													\n\
		background: #0000ff									\n\
	#lyrics													\n\
		background: #0000ff									\n\
"