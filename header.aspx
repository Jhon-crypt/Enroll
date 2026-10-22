<!DOCTYPE html>
<!-- #INCLUDE FILE="dbConn.aspx" -->
<html xmlns="http://www.w3.org/1999/xhtml">
<script runat="server">

</script>
<%
    Dim lsQuery as String = ""
    Dim lsQuery2 as String = ""
    Dim objCmd As SqlClient.SqlCommand = Session("dbConn").CreateCommand()
    Dim objCmdE As SqlClient.SqlCommand = Session("dbConnE").CreateCommand()
    Dim rsData As SqlClient.SqlDataReader

Response.Buffer = True  
Response.Expires =-1500
Response.CacheControl = "no-cache"
Response.ExpiresAbsolute = "01/01/1990 12:00:00 AM"
Session.Timeout = 120
Session("MenuColor") = "#002a64"
Session("HoverColor") = "yellow"
Session("TextColor") = "white"
Session("Logo") = "logo.png"

%>
<head>
<title>SATC Enrollment</title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="-1" />
<meta http-equiv="CACHE-CONTROL" content="NO-CACHE" />
<style type="text/css"> 
b.rtopmain, b.rbottommain{display:block;background: white}
b.rtopmain b, b.rbottommain b{display:block;height: 1px; overflow: hidden; background: <%=Session("MenuColor")%>}
b.r1main{margin: 0 4px}
b.r2main{margin: 0 2px}
b.r3main{margin: 0 1px}
b.rtopmain b.r4main, b.rbottommain b.r4main{margin: 0 1px;height: 1px}

.round-button {
    border: 2px solid #ffffff;
    -moz-border-radius: 7px;
    -webkit-border-radius: 7px;
    -khtml-border-radius: 7px;
    border-radius: 7px;
    background-color:#002a64; 
    color:<%=Session("TextColor")%>; 
    font-family:Verdana; 
    font-size:10pt;
    font-weight:bold; 
    width:100px;
    height:50px; 
    vertical-align:middle; 
    padding-left:10px; 
    padding-right:10px; 
    text-align:center;
    cursor:pointer;
    text-decoration:none;
    margin-left: auto;
    margin-right: auto;
    display:inline-table;
    
}

.round-button-selected {
    -moz-border-radius: 20px;
    -webkit-border-radius: 20px;
    -khtml-border-radius: 20px;
    border-radius: 20px;
    background-color:#002a64; 
    color:<%=Session("TextColor")%>; 
    font-family:Verdana; 
    font-size:8pt; 
    width:auto; 
    vertical-align:middle; 
    padding-bottom:5px; 
    padding-top:5px; 
    padding-left:10px; 
    padding-right:10px; 
    text-align:center;
    cursor:default;
    text-decoration:none;
    margin-left: auto;
    margin-right: auto;
    display:inline-table;
    box-shadow: inset 1px 2px 2px #000000, 1px 2px 2px #333;
}

.round-button:hover {
    text-decoration:none;
    box-shadow: inset 1px 1px 1px #000000, 1px 1px 1px #333;
}

    .rounded {
	    font-family:verdana;
        font-size:14pt;
	    color:black;
        background-color:<%=Session("MenuColor")%>;
	    padding:0px;
        border-spacing:0px;
	    -webkit-border-radius:10px;
	    -moz-border-radius:10px;
	    border-radius:10px;
        border: 5px solid <%=Session("MenuColor")%>;
    }

.caret-down {
    border-color: #ffffff transparent;
    border-style: solid;
    border-width: 4px 4px 0 4px;
    width: 0;
    height: 0;
    margin-left: -2px;
    top: 50%;
    margin-top: 2px;
    position: absolute;
}

.caret-right {
	width: 0; 
	height: 0; 
	border-top: 4px solid transparent;
	border-bottom: 4px solid transparent;
	border-left: 4px solid #ffffff;    
    margin-left: -2px;
    left: 95%;
    margin-top: 4px;
    position: absolute;
}

</style>

<style type="text/css"> 
div#nifty{ margin: 0 10%;background: #9BD1FA}
 
b.rtop, b.rbottom{display:block;background: #FFFFFF}
b.rtop b, b.rbottom b{display:block;height: 1px;
    overflow: hidden; background: <%=Session("MenuColor")%>}
b.r1{margin: 0 5px}
b.r2{margin: 0 3px}
b.r3{margin: 0 2px}
b.rtop b.r4, b.rbottom b.r4{margin: 0 1px;height: 2px}


</style>
<style type="text/css">
<!--
.dragme{position:relative;}
-->
</style>
<script type="text/javascript">
<!--

var ie=document.all;
var nn6=document.getElementById&&!document.all;

var isdrag=false;
var x,y;
var dobj;

function movemouse(e)
{
  if (isdrag)
  {
    dobj.style.left = nn6 ? tx + e.clientX - x : tx + event.clientX - x;
    dobj.style.top  = nn6 ? ty + e.clientY - y : ty + event.clientY - y;
    return false;
  }
}

function selectmouse(e) 
{
  var fobj       = nn6 ? e.target : event.srcElement;
  var topelement = nn6 ? "HTML" : "BODY";

  if (fobj != undefined && fobj != null) {
      while (fobj.tagName != topelement && fobj.className != "dragme" && fobj.tagName != "TEXTAREA" && fobj.tagName != "INPUT" && fobj.tagName != "SELECT") {
          fobj = nn6 ? fobj.parentNode : fobj.parentElement;
          if (fobj == undefined || fobj == null) {
              return true;
          }
      }

      if (fobj.className == "dragme") {
          isdrag = true;
          dobj = fobj;
          tx = parseInt(dobj.style.left + 0);
          ty = parseInt(dobj.style.top + 0);
          x = nn6 ? e.clientX : event.clientX;
          y = nn6 ? e.clientY : event.clientY;
          document.onmousemove = movemouse;
          return false;
      }
  }
}

document.onmousedown=selectmouse;
document.onmouseup=new Function("isdrag=false");

//-->

    function Program() {
        $("#dvProgram").css({ position: 'absolute', top: '325', left: (document.body.clientWidth - 600) / 2, zIndex: 105 });
        $("#dvProgram").show();
    }

    function CloseProgram() {
        $("#dvProgram").hide();
    }

</script>
</head>

<body>

<table class="rounded" border="0" cellpadding="0" cellspacing="0" style="background-color:#002a64;" width="99%">
<tr>
<td bgcolor="#ffffff" valign="top" style="padding:25px;"><img alt="Logo" src="images/<%=Session("Logo")%>" /></td>
<td bgcolor="#ffffff" style="width:100%;text-align:center;font-family:verdana; font-size:24pt; color:#17286d; font-weight:bold; padding:25px;" valign="top">Spring HS Course Enrollment Request <br>  </br> <div style="display:inline-block;width:194px;">&nbsp;</div></td>
</tr>
<tr>
<td bgcolor="white" colspan="2">
