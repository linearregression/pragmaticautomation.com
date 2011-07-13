# Chad Fowler came up with this one: it is compatible with the style files
# at http://www.movablestyle.com. Simply change your rublog.cgi to
# use 
#
# blog = RubLog.new("/Users/dave/Work/blog", CGIRequest.new("movable")) {
#
# and add a link to the styylesheet of your choice:
#
# set_external_stylesheet       "http://www.movablestyle.com/styles/TypePad_Thin/styles-site.css"

PAGE_TEMPLATE= %{
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=<$MTPublishCharset$>" />

<title>%top_title%</title>

IF:external_stylesheet
<link rel="stylesheet" href="%external_stylesheet%" type="text/css" />
ENDIF:external_stylesheet
<link rel="alternate" type="#{RSS_MIME_TYPE}" title="RSS" href="%rss_ref%" />

<script language="javascript" type="text/javascript">
function OpenComments (c) {
    window.open(c,
                    'comments',
                    'width=480,height=480,scrollbars=yes,status=yes');
}

function OpenTrackback (c) {
    window.open(c,
                    'trackback',
                    'width=480,height=480,scrollbars=yes,status=yes');
}
</script>

</head>

<body>

<div id="banner">
<h1><a href="%home_page%" accesskey="1">%top_title%</a></h1>
<!--<span class="description"><$MTBlogDescription$></span>-->
</div>

<div id="content">

<div class="blog">

START:entries

	<h2 class="date">
	%date%
	</h2>

	<div class="blogbody">
	
	<h3 class="title">%title%</h3>
	
IFNOT:synopsis
%-body%
ENDIF:synopsis
IF:synopsis
%-synopsis%<br>
<span class="extended"><a href="%url%">more...</a></span><br />
ENDIF:synopsis
	
	<div class="posted">
IF:index_url
[<a href="%index_url%">%index_name%</a> 
<a href="%print_url%">print</a> 
ENDIF:index_url
IFNOT:index_url
[<a href="%print_url%">print</a> 
ENDIF:index_url
<a href="%url%">link</a> 
<a href="%timeline_url%">all</a>
IF:comment_email_address
<a href="mailto:%comment_email_address%?subject=%top_title%: comment on %title%">comment</a>
ENDIF:comment_email_address
]</td>
	</div>
	
	</div>
	


END:entries

</div>

</div>


<div id="links">



IF:sidebar
START:sidebar
   <div class="sidetitle">%title%</div>
   <div class="side">%-body%</div>
END:sidebar
ENDIF:sidebar

<div class="syndicate">
<a href="%rss_ref%">Syndicate this site (XML)</a>
</div>

<div class="powered">
Powered by<br />
<a href="http://www.pragprog.com/pragdave">Rublog</a><br />
and<br />
<A href="http://www.movablestyle.com">MovableStyle</a>
</div>

</div>

<br clear="all" />

</body>
</html>
}
