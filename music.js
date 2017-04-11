/**
 * MusicWidget
 * ____________________________________________________________________________
 *
 * 	Spectrogram Requires installation of sox https://sox.sourceforge.io/.
 *
 */


command: 'MusicWidgets.widget/musicWidget.sh > /dev/null && cat MusicWidgets.widget/trackinfo.json'

,refreshFrequency: 5000

,render: function(output) {
  //var data = this.parseOutput(output);

	var html  = '<div id="musicWidget">';
			html +=	'<div id="trackInfo">';
				html += '<div id="cover"><img src="albumart.jpg" onerror="this.style.display=\'none\'"/></div>';
				html += '<div id="trackTitle">Songtitle</div>';
				html += '<div id="trackArtist">Artist - Album (2012)</div>';
			html += '</div>';
			html += '<div id="lyrics"></div>';
			html += '<div id="spectrogram"><img src="spectrogram.png" onerror="this.style.display=\'none\'"/></div>';
			html += '<div id="debug"></div>';
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
	
	if(track.Year.length < 2) {
		$(domElement).find('#trackArtist').html(track.Artist + " - " + track.Album );
	} else {
		$(domElement).find('#trackArtist').html(track.Artist + " - " + track.Year + " - " + track.Album );
	}
	
	if(!track.Lyrics || track.Lyrics <= 2) {
		$(domElement).find('#lyrics').css("display","none");
	} else {
		$(domElement).find('#lyrics').css("display","block");
		$(domElement).find('#lyrics').html(track.Lyrics.replace("\n","<br>"));
	}
	
	$(domElement).find('#spectrogram').html('<img src="MusicWidgets.widget/spectrogram.png" onerror="this.style.display=\'none\'"/>');
	
	if(track.hasArtwork) {
		$(domElement).find('#cover').html('<img src="MusicWidgets.widget/albumart.jpg" />');
	}else{
		$(domElement).find('#cover').html('<img src="MusicWidgets.widget/albumart.jpg" onerror="this.style.display=\'none\'"/>');
	}
}


,style: "								\n\
		top: 20px						\n\
		left: 20px						\n\
		color: #fff						\n\
		padding: 15px					\n\
		position: relative				\n\
										\n\
										\n\
	#trackInfo 							\n\
		position: relative				\n\
		padding: 5px					\n\
		height: 100px					\n\
		width: 500px					\n\
		margin: 5px						\n\
		border-radius: 5px				\n\
		background: rgba(0,0,0, .5)		\n\
		float: left \n\
										\n\
										\n\
	#cover 								\n\
		float: left						\n\
										\n\
										\n\
	#cover img 							\n\
		padding-right: 15px				\n\
		width: 100px					\n\
										\n\
										\n\
	#trackTitle							\n\
		font-weight: bold				\n\
										\n\
										\n\
	#lyrics 							\n\
		border-radius: 5px				\n\
		margin: 5px						\n\
		padding: 5px					\n\
		width: 500px					\n\
		background: rgba(0,0,0, .5)		\n\
		float: left						\n\
										\n\
										\n\
	#spectrogram 						\n\
		position: relative				\n\
		top: 5px						\n\
										\n\
										\n\
	#spectrogram img 					\n\
		width: 500px					\n\
		padding: 5px					\n\
		border-radius: 5px				\n\
		background: rgba(0,0,0, .5)		\n\
										\n\
										\n\
	#debug 								\n\
		background: #fff				\n\
		position: absolute				\n\
		top: 10px						\n\
		left: 10px						\n\
		color: #f00						\n\
		display: none					\n\
"