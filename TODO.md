Controller
==========
need to add a before filter to each action, to check if session[:access_token] is nil, and handle it.


View
====
Set the |select/deselct all| button icon.
now the button panel looks like 'clickable', don't do that.

mail#new
validation error css


System
======                                                                   
Feedback page, example:http://railscasts.com/feedback
Unable to load thrift_native extension. Defaulting to pure Ruby libraries
Need pagination...
Scan all notebooks are SO SLOW!!!
Show images directly when user only get one notebook
delay_job to :delete downloaded image and zip file, after say 10 min.
						 :send email later.
Replace session store to other.
Progress bar when scan notebooks.



Issue
=====
some image resource down not contain width and height
can't get thumbnail! Report to evernote later
some images not displayed (in notebook:002 FastSnap)
layout crapped in some cases...
Titles overlay when title has two lines


Future
======
Share with link, or make this notebook public.
Multi-select notebooks?
Hide some notebooks in this site?
Show the image count in notebook index?
Select image size/quality when sending email.
Share this page?
Edit(Zoom in/out, delete) image on the fly

Trouble
=======
still don't have a good route setting

Similar site
============
http://instaport.me/