# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->                           
	# home#show
	if $('div.photo').length > 0
		# select all button click event
		$("#paginate").click (e) ->
			switch e.target.id
				# select all button
				when "select_all" 
					$("#download").find(":checkbox").each ->
						$(this).attr("checked", "checked")
					$("#download").find("div.photo a").each ->
						$(this).css("opacity", 0.4)
						$(this).parent().css("background", "url('/assets/success.png') no-repeat scroll center center")
				# deselect all button
				when "deselect_all" 
					$("#download").find(":checkbox").each ->
						$(this).removeAttr("checked")
					$("#download").find("div.photo a").each ->
						$(this).css("opacity", 1)
						$(this).parent().css("background", "none")
				# download button
				when "a_download"
					# set operation value, so that controller can handle
					$("#operation_input").val("Download")
					$("form").submit()
				# send mail button
				when "a_sendmail"
					# set operation value, so that controller can handle
					$("#operation_input").val("Send Mail")
					$("form").submit()
				when "loadmore"
          alert e.target.href
          $.get(e.target.href, null, null, "script")
          e.preventDefault()
					# $("div.pagination").html("Page is loading...");

		# bind to div#content, catch img tag
		$("#content").click (e) ->
			# if click an image
			if e.target.nodeName == "IMG" && e.target.parentNode.nodeName == "A"
				photo_id = e.target.parentNode.getAttribute("data-photo")
			else
			  return
			
			# cache jquery object
			$chkbox = $("#" + photo_id)
			$img = $(e.target);
			$a = $(e.target.parentNode)
			$div = $(e.target.parentNode.parentNode)
			
			# if image not selected
			if $chkbox.attr("checked") == undefined
				# set to check
				$chkbox.attr("checked", "checked")
				$a.css("opacity", 0.4)
				$div.css("background", "url('/assets/success.png') no-repeat scroll center center")
			else
				$chkbox.removeAttr("checked")
				$a.css("opacity", 1)
				$div.css("background", "none")
			# prevent the url change caused by <a href="#"...>
			e.preventDefault()
					
		resolutionMap = {
		  thumbnail:150,
		  low_resolution:306,
		  standard_resolution:612
		}            
	                
		MIN_SPACE = 20
		currentResolution = "low_resolution"
		s = document.createElement 'style'
		s.setAttribute 'type', 'text/css'
		document.getElementsByTagName('head')[0].appendChild s
	                      
		adjustRowWidth = () ->
			# get one element as sample   
			$sample = $("#content").find(".m:first")
			if $sample.length != 0
				paddingRight = $sample.css("padding-right")
				padding = parseInt(paddingRight, 10)
			else
				padding = 5	             
			
			width = 306 + padding * 2 
			margin = 20 * 2 
			body = $(window).width() - margin
			max = Math.floor(body / width)
			diff = body - (max * width)
			if (diff / (max-1) <= MIN_SPACE)
				max--
				diff += width
			gap = Math.floor(diff / (max-1))
			s.innerHTML = ".m:nth-of-type(#{max}n) {margin-right:0}\n.m {margin-right:#{gap}px}"
		                
		adjustRowWidth()
		$(window).resize (e) ->
			adjustRowWidth()