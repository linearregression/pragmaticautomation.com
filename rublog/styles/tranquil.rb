PAGE_TEMPLATE = %{<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
  <title>%top_title%</title>
  <link rel="alternate" type="#{RSS_MIME_TYPE}" title="RSS" href="%rss_ref%" />
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
  <meta name="generator" content="RubLog" />
  <style type="text/css" media="screen">
    @import url( "/css/tranquil.css" );
  </style>
</head>

<body>
<div id="content">
  
  <div id="header">
    <h1><a href="%home_page%" title="%top_title%">%top_title%</a></h1>
  </div>


  <div id="sidebar">

   <p>
     <center>
     <a href="http://dearelena.wordpress.com/"><img src="http://blogs.pragprog.com/images/pragdave/dearelena.png" alt="Rest peacefully"></a></center>
   </p>

   <div style="padding-top: 0.6in; border-bottom: 1px dotted #999">&nbsp;</div>

   <p>
     <a href="http://canadaonrails.com/"><img src="http://blogs.pragprog.com/images/pragdave/RailsCanada.gif" width="125" height="125" alt="Canada on Rails"></a>
   </p>
  </div>

  <div id="articles">

START:entries
    <div class="article">
      <div class="articlehead">
        <h2 class="articledate">%date%</h2>
	<div class="articlearrow">&nbsp;</div>
        <h2 class="articletitle">
           <a href="%url%" 
              rel="bookmark" 
              title="Permanent Link: %title%">%title%</a>
        </h2>
IFNOT:synopsis
	<div class="articlebody">
          %-body%
	</div>
ENDIF:synopsis
IF:synopsis
	<div class="articlebody">
          %-synopsis%
	  <a class="bodylink" href="%url%">more...</a>
	</div>
ENDIF:synopsis
	</div>
    </div>
<!--
IF:first_entry_xx
    <script type="text/javascript"><!--
      google_ad_client = "pub-9029651581012660";
      google_ad_width = 468;
      google_ad_height = 60;
      google_ad_format = "468x60_as";
      google_ad_type = "texti_image";
      google_ad_channel ="";
      google_color_border = "B0E0E6";
      google_color_bg = "FFFFFF";
      google_color_link = "000000";
      google_color_url = "336699";
      google_color_text = "333333";
    //--></script>
    <script type="text/javascript"
	src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
    </script>
ENDIF:first_entry_xx
-->
END:entries

  </div>
</div>
</body>
</html>
}


__END__
<div id="content">


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

=END
