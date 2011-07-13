PAGE_TEMPLATE = %{
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
<title>%top_title%</title>
<link rel="alternate" type="#{RSS_MIME_TYPE}" title="RSS"
      href="%rss_ref%" />
IF:external_stylesheet
<link rel="stylesheet" type="text/css" href="%external_stylesheet%" />
ENDIF:external_stylesheet

IFNOT:external_stylesheet
<style type="text/css">
body,td {
 font-size:   small;
 line-height: 130%;
}

a { 
   text-decoration: none; 
}

a:link, a:visited {
   color: #2050f0;
}

h1, h2, h3, h4, h5, h6 { 
    color: #446060;
}

pre {
   border-left: 7px solid #e8d8d8;
}

.sidebar {
  font-size: smaller;
  color:     #70b0b0;
}

.sidebar a:link {
  color:     #104020;
}

.sidebar a:visited {
  color:     #104020;
}

.sidebar a:hover {
  color:     #401020;
  font-weight: bold;
}

.Sidebarwarning {
  color:     #902020;
  padding-left:    1em;
}

.sidebarholder {
  border-top: 2px solid #aaaaaa;
  border-left: 2px solid #aaaaaa;
  padding: 0px;
  margin-bottom: 16px;
}

.sidebartitle {
  background: #c0e0e0;
  padding-left: 8px;
}

.sidebarbody {
  background: #f8ffff;
  color:      #a08080;
  padding-left: 8px;
}

.sidebartext {
  color:      #80a0a0;
}

.sidebar TABLE TABLE, .sidebar TABLE TABLE TD {
  color:      #a08080;
  padding-right: 0.5em;
  padding-left:  0em;
  padding-top:   0em;
  padding-bottom:   0em;
}

.sidebarsubhead {
  color:  #503030;
  background: #f8d0d0;
}

.indent {
  margin-left: 1.5em;
}

.catcount {
  color:      #807070;
}

.entry {
  border-top: 2px solid #aaaaaa;
  border-left: 2px solid #aaaaaa;
  padding: 0px;
}

.entrytitlebar {
  background: #e0c0e0;
}

.entrytitle {
  padding-left: 12pt;
  font-size: large;
  font-variant: small-caps;
}

.entrytitledetail {
  text-align: right;
  font-size: x-small;
  padding-right: 12pt;
}

.entrybody {
  padding-left: 36pt;
  padding-right: 12pt;
  padding-bottom: 12pt;
  line-height:   130%;
  background: #f8f0f0;
}

.entrybody h1,h2,h3,h4 {
   line-height: 100%;
}

.pagetitle {
  font-size: xx-large;
  font-family: Arial,Helvetica;
  text-shadow: .18em .15em .2em #223366;
}

.titlemenu {
  font-size: x-small;
  font-family: Arial,Helvetica;
  text-align:  right;
}

.schedhead {
  font-size:   small;
  font-family: Arial,Helvetica;
  text-align:  right;
  font-weight: bold;
  background:  #403030;
  color:       #c0c0c0;
}

.schedentry {
  font-size:   small;
  font-family: Arial,Helvetica;
  text-align:  center;
  background:  #d0c0c0;
}

.schedempty {
  font-size:   small;
  background:  #f0e0e0;
}

.sidebartable {
  color:      #a08080;
}

.c {
  text-align: right;
  padding-right: 0.5em;
  padding-left:  0em;
  padding-top:   0em;
  padding-bottom:   0em;
}
.ctitle {
  text-align: right;
  padding-right: 0.5em;
  padding-left:  0em;
  padding-top:   0em;
  padding-bottom:   0em;
  border-bottom:    1px solid #d0d0d0;
}
.ctotal {
  text-align: right;
  padding-right: 0.5em;
  padding-left:  0em;
  padding-top:   0em;
  padding-bottom:   0em;
  border-top:    1px solid #d0d0d0;
  border-bottom:    1px solid #d0d0d0;
}

.caltoday {
  text-align: right;
  background: #f8d0d0;
}

</style> 
ENDIF:external_stylesheet

</head>
<body>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr valign="bottom">
<td class="pagetitle"><a href="%home_page%">%top_title%</a></td>
<td class="titlemenu" align="center">
IF:prev
<a href="%prev%">&lArr;</a>
ENDIF:prev
%position% 
IF:next
<a href="%next%">&rArr;</a>
ENDIF:next
</td>
<td class="titlemenu">
&bull;
IF:info_url
  <a href="%info_url%">Info</a> &bull;
ENDIF:info_url
  <a href="%fulltext_rss_url%">Syndicate: full</a>/<a href="%synopsis_rss_url%">short</a>
</td>
</tr>
</table>
<hr />
<table>
<tr valign="top"><td>

START:entries
<table class="entry" border="0" cellspacing="0" width="100%">
<tr class="entrytitlebar">
 <td rowspan="2" class="entrytitle"><b>%title%</b></td>
 <td>&nbsp;</td>
 <td class="entrytitledetail">%date%</td>
</tr>
<tr class="entrytitlebar">
 <td></td>
IF:index_url
  <td class="entrytitledetail">[<a href="%index_url%">%index_name%</a> 
<a href="%print_url%">print</a> 
ENDIF:index_url
IFNOT:index_url
  <td class="entrytitledetail">[<a href="%print_url%">print</a> 
ENDIF:index_url
<a href="%url%">link</a> 
<a href="%timeline_url%">all</a>
IF:comment_email_address
<a href="mailto:%comment_email_address%?subject=%top_title%: comment on %title%">comment</a>
ENDIF:comment_email_address
]</td>
</tr>
<tr class="entrybody"><td colspan="3" class="entrybody">
IFNOT:synopsis
%-body%
ENDIF:synopsis
IF:synopsis
%-synopsis%<br>
<a href="%url%">more...</a> 
ENDIF:synopsis
</td></tr>
</table>
<p />
END:entries

</td>
IF:sidebar
<td>&nbsp;</td>
<td class="sidebar">
<table width="100%" border="0" cellspacing="0" class="sidebarholder">
START:sidebar
<tr><td class="sidebartitle">%title%</td></tr>
<tr><td class="sidebarbody">%-body%</td></tr>
END:sidebar
</table>
</td>
ENDIF:sidebar
</tr>
</table>
<hr />
<table  border="0" cellpadding="0" cellspacing="0" width="100%">
IF:copyright
<tr>
<td align="right"><i style="font-size: 1">Copyright &copy; %copyright%</i></td>
ENDIF:copyright
</tr>
</table>
</body>
</html>
}


