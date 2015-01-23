env = require '../env.coffee'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
vent = require '../vent.coffee'
_ = require 'underscore'
		
###
opts:
	icon:	icon name (e.g. user)
###
icon = (opts = {}) ->
	cls = "glyphicon glyphicon-#{opts.icon}"
	opts.class ?= cls
	if opts.class != cls
		opts.class += ' ' + cls
	opts = _.pick opts, 'class', 'html'
	$('<span>', opts)[0].outerHTML
	
###
opts:
	prependIcon:	icon to prepend to the btn (e.g. search)
	appendIcon:		icon to append to the btn
###
btn = (opts = {}) ->
	opts = _.defaults opts, html: '', class: 'btn btn-default'
	if opts.prependIcon
		opts.html = icon(icon: opts.prependIcon) + opts.html
	if opts.appendIcon
		opts.html += icon(icon: opts.appendIcon)
	opts = _.pick opts, 'class', 'html'
	$('<a>', opts)[0].outerHTML
	
###
opts:
	btns:	array of html string buttons
###
btngrp = (opts = {}) ->
	opts.html = opts.btns.join('')
	opts = _.pick opts, 'html', 'class'
	$('<div>', opts)[0].outerHTML()
	
input = (opts = {}) ->
	opts = _.defaults opts, type: 'text', value: '', class: 'form-control' 
	$('<input>', opts)[0].outerHTML
	
inputgrp = (opts = {}) ->
	opts = _.defaults opts, class: 'input-group'
	opts.html = input _.pick opts, 'placeholder'
	if opts.prependIcon
		opts.html = icon(icon: opts.prependIcon, class: 'input-group-addon') + opts.html
	if opts.appendIcon
		opts.html += icon(icon: opts.appendIcon, class: 'input-group-addon')
	opts = _.pick opts, 'html', 'class'
	$('<div>', opts)[0].outerHTML
	
search = (opts = {}) ->
	opts = 	_.defaults opts, id: 'search'
	opts.html = inputgrp
		prependIcon:	'search'
		placeholder:	'Search'
	$('<form>', opts)[0].outerHTML
		
link = (opts = {}) ->
	$('<a>', opts)[0].outerHTML

menuitem = (opts = {}) ->
	$('<li>', opts)[0].outerHTML
		
dropdown = (opts = {}) ->
	$('<ul>', opts)[0].outerHTML
			
###
opts:
	username is defined in window.app.user
###
curruser = (opts = {}) ->
	html = [	
		link
			'html':			"#{icon(icon: 'user')} #{window.app.user.get('username')} <span class='caret'></span>"
			'class':		'dropdown-toggle'
			'data-toggle':	'dropdown'
		dropdown 
			'class': 'dropdown-menu'
			'html':
				menuitem 
					'html':
						link
							'html':	'Logout'
							'href':	'#logout'			
	].join('')
	_.defaults opts, 'class': 'dropdown', 'html': html
	$('<li>', opts)[0].outerHTML
		
###
opts:
	model:
		brand:	projectName
		left:	array of html string
		right:	array of html string
###
navbar = (opts = {}) ->
	html = """
		<div class='container-fluid'>
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target=".navbar-collapse">
					<span class="sr-only">Toggle navigation</span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</button>
				<a class="navbar-brand" href="#">#{opts.brand}</a>
			</div>
			<div class="collapse navbar-collapse">
  				<ul class="nav navbar-nav navbar-left">
  					#{ opts.left.join('') }
  				</ul>
  				#{ opts.other.join('') }
  				<ul class="nav navbar-nav navbar-right">
  					#{ opts.right.join('') }
  				</ul>
  			</div>
		</div>
	"""
	opts = _.defaults opts, 'class': 'navbar navbar-default', 'html': html 
	opts = _.pick opts, 'html', 'class'
	$('<nav>', opts)[0].outerHTML
		
class ModalView extends Marionette.LayoutView
	className:	'modal fade'
	
	attributes:
		'aria-hidden':	'true'
		
	template: (data) =>
		"""
		  <div class="modal-dialog">
		    <div class="modal-content">
		      <div class="modal-header">
		        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		        <h4 class="modal-title"></h4>
		      </div>
		      <div class="modal-body">
		      </div>
		    </div>
		  </div>
		"""
		
	regions:
		'modal-body':	'.modal-body'
		
	onRender: ->
		if @data?.title
			@$('.modal-title').html(@data.title)
		if @data?.body
			@getRegion('modal-body').show(@data.body)
		
	# opts.view: view to be inserted into dialog body
	constructor: (opts = {}) ->
		super(opts)
		vent.on 'show:cmd', @show
		vent.on 'hide:cmd', @hide
		
	destroy: ->
		super()
		vent.off 'show:cmd', @show
		vent.off 'hide:cmd', @hide
		
	# data:
	#	title:	string put on the modal title
	#	body:	view to be rendered on the modal body
	show: (data) =>
		@data = data
		@render()
		@$el.modal('show')
		
	hide: =>
		@$el.modal('hide')
	
class PageView extends Marionette.LayoutView
	el:	'body'
	
	template: (data) =>
		opts =
			brand:	'Mobile'
			left:	[
				menuitem
					html: 
						link
							href: '#device/list'
							html: 'Device'
				menuitem
					html:	
						link
							href: '#user/list'
							html: 'User'
			]
			right:	[
				curruser()
			]
			other: [
				search
					class: 'navbar-form navbar-left'
			]
		navbar(opts) + "<div id='popup'></div><div id='cmd'></div><div id='content'></div>"
		
	events:
		'click a[href]':			'hide'
		'click .glyphicon-search':	'hide'
		'input #search':			'search'
		
	regions:
		popup:		'#popup'
		content:	'#content'

	onRender: ->
		@getRegion('popup').show new ModalView()
			
	search: (event) ->
		vent.trigger 'search', $(event.target).val()
		
	show: (view) ->
		if @_firstRender
			@render()
		@getRegion('content').show view
		@$('#search input').val('')
		
	# hide navbar if navbar-toggle is displayed in small screen factor
	hide: ->
		if $('.navbar-toggle').css('display') != 'none'
			$('.navbar-collapse').toggleClass('in', false)
		
class ModelView extends Marionette.ItemView
	template: (data) =>
		"<div class='model'>#{ModelView.show(@model)}</div>"

	@show: (obj) ->
		if _.isNaN(obj) or _.isNull(obj) or _.isUndefined(obj)
			return ''
			
		ret = ''
		
		if typeof obj == 'object'
		
			if obj instanceof Backbone.Collection			# Collection
				obj.each (value, key, list) ->
					ret += """
						<div class='field'>
							#{ModelView.show value}
						</div>
					""" 
				
			else if obj instanceof Backbone.Model			# Model
				view = obj.pick obj.showFields()			# show attributes only if defined in model.showFields()
				_.each view, (value, key, list) ->
					ret += """
						<div class='field'>
							<label class='key'>#{obj.schema[key].title}</label>
							#{ModelView.show value}
						</div>
					"""
					
			else if _.isArray obj
				_.each obj, (value) ->
					ret += """
						<div class='field'>
							#{ModelView.show value}
						</div>
					""" 
					
			else if _.isDate obj
				ret += obj.toLocaleString()
									
			else	 										# Plain Object
				_.each obj, (value, key, list) ->
					ret += """
						<div class='field'>
							<label class='key'>#{key}</label>
							#{ModelView.show value}
						</div>
					"""
			
		else												# Primitive Type
			ret += "<span class='value'>#{obj}</span>"
		
		return ret
		
module.exports =
	html:
		link:		link
		icon:		icon
		btn:		btn
		btngrp:		btngrp
		input:		input
		menuitem:	menuitem
		dropdown:	dropdown
		search:		search
		curruser:	curruser
		navbar:		navbar
	ModelView:	ModelView
	ModalView:	ModalView
	PageView:	PageView