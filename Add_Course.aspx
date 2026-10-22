<%
    Dim liCourses As Integer = 0

    If IsNothing(Session("NumCourses")) Then
        liCourses = 1
        Session("NumCourses") = 1
    ElseIf Session("NumCourses").ToString() = "" Then
        liCourses = 1
        Session("NumCourses") = 1
    Else
        liCourses = CInt(Session("NumCourses"))
    End If
    
    'For Each objReq As Object In Request.Form
    'Session(objReq) = Request(objReq)
    'Next
    
    liCourses += 1
    Session("NumCourses") = liCourses
    Response.Redirect(Request("Refer"))
%>
