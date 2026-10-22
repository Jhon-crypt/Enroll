</td>
</tr>
</table>
<center>
<font face="arial, verdana, sans" color="#000000" size="1">
	Copyright © <%=Year(DateTime.Now)%> SATC&nbsp;
</font>
</center>


 </body>
<script type="text/javascript">
    function Open(id,width, top) {
        $("#dv" + id).show("Fast");
        $("#dv" + id).css("left", (document.body.clientWidth - width)/2);
        $("#dv" + id).css("top", top);
    }

    function Close(id) {
        $("#dv" + id).hide();
    }


</script>
</html>
<!-- #INCLUDE FILE="dbClose.aspx" -->