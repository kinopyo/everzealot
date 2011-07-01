# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
Everzealot =
  foo: (number) -> alert number

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
			$(this).parent().css("background", "none")
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
			$(this).parent().css("background", "none")
		# prevent the url change caused by <a href="#"...>
		e.preventDefault()
	)
	
	# download link click event
	$("#a_download").click((e) ->
		# set operation value
		$("#operation_input").val("Download")
		$("form").submit()
	)
	# send mail link click event
	$("#a_sendmail").click((e) ->
		# set operation value
		$("#operation_input").val("Send Mail")
		$("form").submit()
	)
	
	# resolutionMap = {
	#   thumbnail:150,
	#   low_resolution:306,
	#   standard_resolution:612
	# }
	
	# MIN_SPACE = 20
	# 	currentResolution = "low_resolution"
	# document.createElement('style')
	#   s.setAttribute('type', 'text/css')
	#   document.getElementsByTagName('head')[0].appendChild(style)
	
	# $(window).resize((e) ->
	# 	# get one element as sample
	# 	$sample = $("#content").find(".m:first")
	# 	if $sample
	# 		paddingRight = $sample.css("padding-right")
	# 		padding = parseInt(paddingRight, 10)
	# 	else
	# 		padding = 5
	# 
	#     width = 306 + padding * 2
		#     width = 306 + padding * 2
		#     margin = 20 * 2
		#     body = $(window).width() - margin
		#     max = Math.floor(body / width)
		#     diff = body - (max * width)
		#     if (diff / (max-1) <= MIN_SPACE)
		# 	    max--
		# 	    diff += width
		#     gap = Math.floor(diff / (max-1))
		# innerHTML = ".m:nth-of-type("+max+"n) {margin-right:0}\n.m {margin-right:"+ gap +"px}"
		# console.log innerHTML
	# )

	# adjustRowWidth: ->
	# 	# get one element as sample
	# 	$sample = $("#content").find(".m:first")
	#     padding = $sample ? parseInt($sample.css("padding-right"),10)) : 5
	#     width = resolutionMap[currentResolution] + padding * 2
	#     margin = 20 * 2
	#     body = $(window).width() - margin
	#     max = Math.floor(body / width)
	#     diff = body - (max * width)
	#     if (diff / (max-1) <= MIN_SPACE)
	#        max--
	#        diff += width
	#     gap = Math.floor(diff / (max-1))
	#     this.styleNode.innerHTML = ".m:nth-of-type("+max+"n) {margin-right:0}\n.m {margin-right:"+ gap +"px}"