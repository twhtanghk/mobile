 # GroupController
 #
 # @description :: Server-side logic for managing groups
 # @help        :: See http://links.sailsjs.org/docs/controllers
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'

module.exports =
	# req.user: current login user
	# users:	array of users url
	# data:		message data to be sent
	create: (req, res) ->
		values = actionUtil.parseValues(req)
		sails.models.user
			.find()
			.where(email: values.users)
			.populateAll()
			.then (to) ->
				sails.services.rest
					.gcmPush to, values.data
					.then res.ok, res.serverError
			.catch res.serverError