<%
    Session("Deleted_Courses") &= " " & Request("Course") & " "
    Response.Redirect(Request("Refer"))
%>
