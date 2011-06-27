# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
	$("#select_all").click((e) ->
		$("#download").find(":checkbox").each ->
			$(this).attr("checked", "checked")
	)
	
	$("#deselect_all").click((e) ->
		$("#download").find(":checkbox").each ->
			$(this).removeAttr("checked")
	)