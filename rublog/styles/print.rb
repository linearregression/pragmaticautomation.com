PAGE_TEMPLATE = %{
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" 
"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
<title>%top_title%</title>
<link rel="alternate" type="#{RSS_MIME_TYPE}" title="RSS"
      href="%rss_ref%" />
<style type="text/css">
body {
 font-size:   small;
 line-height: 130%;
}

a { text-decoration: none; }

.entrytitle {
  margin-top: 0.5in;
  font-size: x-large;
  font-variant: small-caps;
  border-bottom: solid;
}

.entrydate {
  font-size: small;
  margin-bottom: 1ex;
}

.entrybody {
  margin-bottom: 0.5in;
}

.entrybody h1,h2,h3,h4 {
   line-height: 100%;
}

.pagetitle {
  font-size: xx-large;
  font-family: Arial,Helvetica;
}

</style> 
</head>
<body>
<div class="pagetitle">%top_title%</div>
<hr />

START:entries
<div class="entrytitle">%title%</div>
<div class="entrydate">%date% - <a href="%full_url%">%full_url%</a></div>
<div class="entrybody">
%-body%
</div>
END:entries

</body>
</html>
}


