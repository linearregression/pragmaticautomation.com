# Purple-style template, based on Glenn's glv.rb

PAGE_TEMPLATE = %{<?xml version="1.0" encoding="utf-8?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
    <title>%top_title%</title>
IF:external_stylesheet
    <link rel="stylesheet" type="text/css" href="%external_stylesheet%" />
ENDIF:external_stylesheet
IFNOT:external_stylesheet
    <link rel="stylesheet" type="text/css" href="/purple.css" />
ENDIF:external_stylesheet
    <link rel="alternate" type="#{RSS_MIME_TYPE}" title="RSS"
          href="%rss_ref%" />
    <title>%top_title%</title>
</head>
<body>

<div class="Header">

<table>

  <tr>
    <td class="NameCell">
      <div class="Title">
        <h1><a href="%home_page%">%top_title%</a></h1>
      </div> 
    </td>
  </tr>


</table>

</div>

<div class="Content">

<div class="BlogNav">

<div style="text-align: right; float: right; margin-right: 0; margin-left: auto;">
&bull;
IF:info_url
  <a href="%info_url%">info</a> &bull;
ENDIF:info_url
  <a href="%fulltext_rss_url%">Syndicate: [full]</a>&nbsp;<a href="%synopsis_rss_url%">[short]</a>
</div>

<div style="text-align: left;">
IF:prev
<a href="%prev%">&laquo;</a>
ENDIF:prev
%position% 
IF:next
<a href="%next%">&raquo;</a>
ENDIF:next
</div>

</div> <!-- BlogNav -->

<div class="Content">
<table>
<tr valign="top">
<td width="70%">

START:entries
<div class="item">

<div class="itemhdr">
<span class="itemtitle">%title%</span><br/> <!-- ??? Would like to have <a name= -->
<span class="itemtime">%date%</span>&nbsp;&nbsp;&nbsp;
IF:index_url
  <span class="entrytitledetail">[<a href="%index_url%">%index_name%</a> 
<a href="%print_url%">print</a> 
ENDIF:index_url
IFNOT:index_url
  <span class="entrytitledetail">[<a href="%print_url%">print</a> 
ENDIF:index_url
<a href="%url%">link</a> 
<a href="%timeline_url%">all</a>
IF:comment_email_address
<a href="mailto:%comment_email_address%?subject=%top_title%: comment on %title%">comment</a>
ENDIF:comment_email_address
]</span>
</div> <!-- itemhdr -->

<!-- ??? Do I want anything to do with synopses? -->
<div class="itembody">
IFNOT:synopsis
<p>%-body%
ENDIF:synopsis
IF:synopsis
<p>%-synopsis%<br>
<a href="%url%">more...</a> 
ENDIF:synopsis
</div> <!-- itembody -->
</div> <!-- item -->
END:entries

</td>
<td width="5%">&nbsp;</td>
<td width="25%">


IF:sidebar

START:sidebar
<div class="sidebox">
<h2>%title%</h2>
<div class="sideboxContent">
%-body%
</div>
</div>
END:sidebar

ENDIF:sidebar
</td>
</tr>
</table>

</div> <!-- Content -->

</div> <!-- Content (again!) -->


<div class="Footer">
IF:copyright
Copyright &copy; %copyright%.<br/>
ENDIF:copyright
</div>

</body>
</html>
}
