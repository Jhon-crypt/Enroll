<script runat="server">

    Public dbConn As System.Data.SqlClient.SqlConnection
    Public dbConnE As System.Data.SqlClient.SqlConnection
    Public gsConn As String

Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)

	Dim lsURL
	Dim lsConn
	
	Session.Timeout = 900


        gsConn = "server=SOnisWeb-DB,1433;uid=utility;pwd=Ut1l1ty!123;initial catalog=SATC_Sonisweb;MultipleActiveResultSets=true;"
        dbConn = New System.Data.SqlClient.SqlConnection(gsConn)
        dbConn.Open()
        dbConnE = New System.Data.SqlClient.SqlConnection(gsConn)
        dbConnE.Open()
	
        Session("dbConn") = dbConn
	    Session("dbConnE") = dbConnE
	
	
	'If uCase(Request("HTTPS")) <> "ON" Then
	'	lsURL = "Https://" & Request("SERVER_NAME") 
	'	lsURL = lsURL & Request("URL") 
	'	If Request("QUERY_STRING") > "" Then
	'		lsURL = lsURL & "?" & Request("QUERY_STRING")
	'	End If
	'	Response.Redirect(lsURL)
	'End If
	
End Sub

Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
	Session("dbConn").Close
	Session("dbConn") = Nothing
	Session("dbConnE").Close
	Session("dbConnE") = Nothing
End Sub
</script>