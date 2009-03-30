AudioPlayer.setup("/swf/player.swf", {width: 290})

function embed_audio(divid, file){
  AudioPlayer.embed(divid, {soundFile: "http://media.callcongress.net/audio/"+file})
}
