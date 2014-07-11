envClient = require './client/env.coffee'
url = "https://#{envClient.oauth2.authServer}/org"
serverUrl =	"http://localhost:3000/#{envClient.proj}"

env =
	proj:	envClient.proj
	role:
		all:	'All Users'
		admin:	'Admin'
	serverUrl:	serverUrl		# app server url
	path:		envClient.path
	dbUrl:		"mongodb://#{envClient.proj}rw:password@localhost/#{envClient.proj}"
	oauth2:
		authorizationURL:	"#{url}/oauth2/authorize/"
		tokenURL:			"#{url}/oauth2/token/"
		profileURL:			"#{url}/api/users/me/"
		verifyURL:			"#{url}/oauth2/verify/"
		callbackURL:		"#{serverUrl}/auth/provider/callback"
		provider:			require 'passport-ttsoon'
		authURL:			"/auth/provider"
		cbURL:				"/auth/provider/callback"
		clientID:			"#{envClient.proj}DEVAuth"
		clientSecret:		'pass1234'
		scope:		[
			"https://#{envClient.oauth2.authServer}/org/users"
		]
	pageSize:	10
	log4js: 	require 'log4js'
	
env.log4js.configure
	appenders:	[ type: 'console' ]
	
module.exports = env