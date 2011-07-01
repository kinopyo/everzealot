Controller
==========
need to add a before filter to each action, to check if session[:access_token] is nil, and handle it.


View
====
/show -> image padding too short..
			-> after getting thumbnail from evernote, the small size image need to set to center
home#show -> when drag the window to change the width,need to set the margin-right dynamically.
Set the |select/deselct all| button icon.
now the button panel looks like 'clickable', don't do that.

mail#new
validation error css


System
======
Unable to load thrift_native extension. Defaulting to pure Ruby libraries


Issue
=====
some image resource down not contain width and height
https://sandbox.evernote.com/shard/s1/res/d3d1bbdc-5742-4c82-a65d-7138be9a5f7a
https://sandbox.evernote.com/shard/s1/thm/res/d3d1bbdc-5742-4c82-a65d-7138be9a5f7a
can't get thumbnail! Report to evernote later


== 悩み
still don't have a good route setting

delay_job to delete downloaded image and zip file, after say 10 min.
But heroku worker cause 15$ per month... struggle.
