mobile
======

Web Application to register mobile device with its GCM registration ID, model, and version

Web Server URL 
---------------------------------------------------------
*   Device

```
    get device/:regid/:model/:version - register mobile device of the input registration ID, model, and version for the authenticated user
```

Configuration
=============

*   git clone https://github.com/twhtanghk/mobile.git
*   cd mobile
*   npm install
*	create mongo database
*	create api key for authorization code and implicit grant in authentication server
*	update environment variable PORT in start.sh
    
```
    export PORT=8005
```

*   update environment variable proj, authServer in client/env.cofffee

```
    proj = 'mobile'
	authServer = 'mob.myvnc.com'
	env =
		clientID:		"mobile"
```

*	update environment variable serverUrl and dbUrl in env.coffee

```
	serverUrl =	"http://localhost:3000/#{envClient.proj}"
	env =
		dbUrl:			"mongodb://mobilerw:password@localhost/mobile"
		clientID:		"mobileAuth"
		clientSecret:	'password'	
```