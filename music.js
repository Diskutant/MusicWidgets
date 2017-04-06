/**
 * MusicWidget
 * ____________________________________________________________________________
 *
 * 	Spectrogram Requires installation of sox https://sox.sourceforge.io/.
 *
 */


command: 'MusicWidgets.widget/musicWidget.sh > /dev/null && cat MusicWidgets.widget/trackinfo.json'

,refreshFrequency: 10000


,render: function(output) {
  //var data = this.parseOutput(output);
	var html  = '<div id="musicWidget">';
			html += '<div id="debug"></div>';
			html += '<div id="track"></div>';
			html += '<div id="trackinfo"><div id="cover"><img src="MusicWidgets.widget/albumart.jpg" onerror="this.style.display=\'none\'"/></div><div id="trackTitle"></div><div id="trackArtist"></div>';
   			html += '<div id="spectrogram"><img src="MusicWidgets.widget/spectrogram.png" onerror="this.style.display=\'none\'"/></div>';
   			html += '<div id="lyrics"></div>';
   		html += '</div>';

  return html;
}


,update: function(output, domElement) {
	if(!output || output.length <= 10 ) { 
		$(domElement).find('#musicWidget').parent().css("display","none");
		return; 
	}
	$(domElement).find('#musicWidget').parent().css("display","block");
	$(domElement).find('#debug').html(output);
	track = $.parseJSON(output);
	$(domElement).find('#trackTitle').html(track.Title);
	$(domElement).find('#trackArtist').html(track.Artist + " - " + track.Album + " (" + track.Year + ")");
	$(domElement).find('#lyrics').html(track.Lyrics);
//	$(domElement).find('#spectrogram').html('<img src="MusicWidgets.widget/spectrogram.png" onerror="this.style.display=\'none\'"/>');
	if(track.hasArtwork) {
//		$(domElement).find('#cover').html('<img src="MusicWidgets.widget/albumart.jpg" onerror="this.style.display=\'none\'"/>');
		$(domElement).find('#cover').html('<img src="MusicWidgets.widget/albumart.jpg" />');
	}
}


,style: "													\n\
	top: 20px												\n\
	left: 20px												\n\
	color: #fff												\n\
	padding: 15px											\n\
	border-radius: 5px										\n\
	width: 400px 											\n\
	background: rgba(#000, .5)								\n\
	display: none											\n\
															\n\
	#musicWidget											\n\
		top: 10px											\n\
		left: 10px											\n\
															\n\
	#trackinfo												\n\
		color: #fff											\n\
															\n\
	#cover													\n\
		float: left											\n\
															\n\
	#trackTitle												\n\
		color: #fff											\n\
		font-weight: bold									\n\
															\n\
	#spectrogram img										\n\
		width: 500px										\n\
		padding-top: 5px									\n\
															\n\
	#debug													\n\
		background: #fff									\n\
		color: #f00											\n\
		display: none										\n\
															\n\
	#cover img												\n\
		padding-right: 15px									\n\
		float: left											\n\
		width: 100px										\n\
															\n\
"