# This style is an adaptation of the default XHTML that comes with Wordpress
# (http://www.wordpress.org) by Matt Mullenweg.
# Using this style with RubLog, you can now use (probably) any CSS that is 
# created for Wordpress.
PAGE_TEMPLATE = %{
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
	<title>%top_title%</title>
        <link rel="alternate" type="#{RSS_MIME_TYPE}" title="RSS" href="%rss_ref%" />
	
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<meta name="generator" content="RubLog" /> <!-- leave this for stats -->

	<style type="text/css" media="screen">
		@import url( %external_stylesheet% );
	</style>

	
</head>

<body>
<div id="rap">
<h1 id="header"><a href="%home_page%" title="%top_title%">%top_title%</a></h1>

<div id="content">

START:entries
<h2>%date%</h2>	
<div class="post">
	 <h3 class="storytitle" id="post-29"><a href="%url%" rel="bookmark" title="Permanent Link: %title%">%title%</a></h3>
	<div class="storycontent">
IFNOT:synopsis
%-body%
ENDIF:synopsis
IF:synopsis
%-synopsis%<br>
<a href="%url%">more...</a>
ENDIF:synopsis
	</div>
	
        <!-- Uncomment this and change it if you have a comments hack...
		like Jim Weirich does, for example -->
	<!--<div class="feedback">
		<a href="sample.php?wpstyle=type&amp;c=1#comments">Comments (2)</a> 
	</div>-->
	
</div>
END:entries

</div>


<div id="menu">

<ul>
IF:sidebar
START:sidebar
 <li id="%title%">%title%:<br />
%-body%
 </li>
END:sidebar
ENDIF:sidebar
 <li id="meta">Meta:
 	<ul>
		<li><a href="%fulltext_rss_url%" title="Syndicate this site using RSS"><abbr title="Really Simple Syndication">RSS</abbr></a></li>

		<li><a href="http://validator.w3.org/check/referer" title="This page validates as XHTML 1.0 Transitional">Valid <abbr title="eXtensible HyperText Markup Language">XHTML</abbr></a></li>
		<li><a href="http://pragprog.com/pragdave/" title="Powered by RubLog">RubLog</a></li>
	</ul>
 </li>
</ul>

</div>

</div>

<p class="credit"><cite>Powered by <a href="http://pragprog.com/pragdave/Tech/Blog" title="Powered by RubLog"><strong>RubLog</strong></a></cite></p>
</body>
</html>
}
