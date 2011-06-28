# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
	$("#select_all").click((e) ->
		$("#download").find(":checkbox").each ->
			$(this).attr("checked", "checked")
		$("#download").find("div.photo a").each ->
			$(this).css("opacity", 0.4)
			$(this).parent().css("background", "url('/assets/success.png') no-repeat scroll center center")
	)
	
	$("#deselect_all").click((e) ->
		$("#download").find(":checkbox").each ->
			$(this).removeAttr("checked")
		$("#download").find("div.photo a").each ->
			$(this).css("opacity", 1)
	)
	
	$("div.photo").find("a").click((e) ->
		id = $(this).attr("data-photo")

		# not checked
		$chkbox = $("#" + id)
		$img = $(this).find("img");
		if $chkbox.attr("checked") == undefined
			# set to check
			$chkbox.attr("checked", "checked")
			$(this).css("opacity", 0.4)
			$(this).parent().css("background", "url('/assets/success.png') no-repeat scroll center center")
		else
			$chkbox.removeAttr("checked")
			$(this).css("opacity", 1)
			
		# prevent the url change caused by <a href="#"...>
		e.preventDefault()
	)
	
	# download link
	$("#a_download").click((e) ->
		# set operation value
		$("#operation_input").val("Download")
		$("form").submit()
	)
	# send mail link
	$("#a_sendmail").click((e) ->
		# set operation value
		$("#operation_input").val("Send Mail")
		$("form").submit()
	)
	
	