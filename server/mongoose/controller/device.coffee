env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'

error = (res, msg) ->
	res.json 500, error: msg

class Device

	@register: (req, res) ->
		data = 
			regid:		req.params.regid
			model: 		req.params.model
			version:	req.params.version
		data.createdBy = req.user 
		model.Device.findOrCreate data, (err, device, created) ->
			if err
				return error res, err
			res.json device			
	
	@list: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		cond = {}
		if req.query.search 
			pattern = new RegExp(req.query.search, 'i')
			fields = _.map model.Device.search_fields(), (field) ->
				ret = {}
				ret[field] = pattern
				return ret
			cond = $or: fields 
		
		order_by = lib.order_by model.Device.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Device.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		model.Device.find(cond, null, opts).populate('createdBy updatedBy').sort(order_by).exec (err, devices) ->
			if err
				return error res, err
			model.Device.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: devices}
			
	@create: (req, res) ->
		data = req.body
		data.createdBy = req.user 
		device = new model.Device data
		device.save (err) =>
			if err
				return error res, err
			res.json device			
				
	@read: (req, res) ->
		id = req.param('id')
		model.Device.findById(id).populate('createdBy updatedBy').exec (err, device) ->
			if err or device == null
				return error res, if err then err else "Device not found"
			res.json device			
			
	@update: (req, res) ->
		id = req.param('id')
		model.Device.findOne {_id: id, __v: req.body.__v}, (err, device) ->
			if err or device == null
				return error res, if err then err else "Device not found"
			
			attrs = _.omit req.body, '_id', '__v', 'dateCrated', 'createdBy', 'lastUpdated', 'updatedBy'
			_.map attrs, (value, key) ->
				device[key] = value
			device.updatedBy = req.user
			device.save (err) ->
				if err
					error res, err
				else res.json device				
					
	@delete: (req, res) ->
		id = req.param('id')
		model.Device.findOne {_id: id}, (err, device) ->		
			if err or device == null
				return error res, if err then err else "Device not found"
			
			device.remove (err, device) ->
				if err
					error res, err
				else
					res.json {deleted: true}
					
module.exports = 
	Device: 		Device