options = 
  appkeyFile: "#{__dirname}/spotify_appkey.key"
  cacheFolder: 'cache'
  settingsFolder: 'settings'

spotify = require("#{__dirname}/../lib/spotify")(options)

play = (track)->
  console.log track.artists[0].name + ' - ' + track.name
  spotify.player.play track

wait = (playlist)->
  track = playlist.getTracks()[0]
  track.position = 0
  spotify.waitForLoaded [track], play

ready = ->
  starredPlaylist = spotify.sessionUser.starredPlaylist
  spotify.waitForLoaded [starredPlaylist], wait


spotify.on ready: ready
user = require "#{__dirname}/spotify_user"
spotify.login user.name, user.password, false, false