<!-- #INCLUDE FILE="DBConn.aspx" -->
COURSE_RESPONSE
<%
    Dim lsFac As String = ""
    Dim lsCourseId As String = ""
    Dim ldFee As Double = 0.0
    Dim lsSid As String = ""
    Dim lsFeeSec As Object
    Dim lsSection As String = "1"
    Dim ldCred As Double = 0.0
    Dim lsCamp As String = ""
    
    If Request("Section") > "" Then
        lsSection = Request("Section")
    End If
    
    If Request("mode") = "sec" Then
        Session("section_" & Request("index")) = Request("Sec")
        Response.End()
    End If
    
    If Request("hs_course") > "" Then
        If Request("Online") = "1" Then
            lsCamp = "ONL"
        Else
            lsCamp = Session("camp_cod")
        End If
        
        
        Dim objCmd As SqlClient.SqlCommand = Session("dbConn").CreateCommand()
        Dim rsData As SqlClient.SqlDataReader
        objCmd.CommandText = "Select course.*, semester.sm_desc, crssect.lead_fac, campus.camp_txt, timedesc, crssect.sid, crssect.memo  "
        objCmd.CommandText &= "From course Left Join campus_course On campus_course.course=course.course "
        objCmd.CommandText &= "Inner Join crssect on crssect.crs_id = course.crs_id And crssect.camp_cod = '" & lsCamp & "' "
        objCmd.CommandText &= "Inner Join semester on semester.semester = crssect.semester "
        objCmd.CommandText &= "Inner Join campus on campus.camp_cod = crssect.camp_cod And crssect.semester = " & Session("term_semester")
        'objCmd.CommandText &= "Left Join feessec on feessec.sid = crssect.sid "
        objCmd.CommandText &= "Where course.crs_id = " & Request("hs_course") & " And section = '" & lsSection & "' And crssect.sch_yr = '" & Session("term_year") & "' "
        rsData = objCmd.ExecuteReader()
        If rsData.Read Then
            Response.Write(Trim(rsData("crs_txt")) & "|")
            Response.Write(Trim(rsData("course")) & "|")
            Response.Write(Trim(rsData("dept_cod")) & "|")
            Response.Write(Trim(rsData("credits")) & "|")
            Response.Write(Trim(rsData("npercred")) & "|")
            Response.Write(Trim(rsData("sm_desc")) & "|")
            Response.Write(Replace(Trim(rsData("camp_txt")),"'","") & "|")
            Response.Write(Trim(rsData("memo") & "") & "|")
            lsFac = Trim(rsData("lead_fac"))
            lsCourseId = Trim(rsData("crs_id"))
            ldFee = rsData("credits") * rsData("npercred")
            ldCred = rsData("credits")
            'If rsData("fee_amnt") <> vbNull Then
            'ldFee += CDbl(rsData("fee_amnt"))
            'End If
            lsSid = rsData("sid")
            Session("crs_id_" & Request("index")) = Trim(rsData("crs_id"))
        End If
        rsData.Close()
        objCmd.CommandText = "Select first_name, last_name from name Where soc_sec = '" & lsFac & "'"
        rsData = objCmd.ExecuteReader()
        If rsData.Read Then
            Response.Write(Trim(rsData("last_name")) & "|")
        End If
        rsData.Close()
        
        objCmd.CommandText = "Select amount from CRSAFF Where crs_id = '" & lsCourseId & "' And affiliation_cod='HS'"
        rsData = objCmd.ExecuteReader()
        If rsData.Read Then
            ldFee = ldCred * rsData("amount")
        Else
            ldFee = 0
        End If
        rsData.Close()
        
        'If Session("camp_cod") = "ONL" Then
        'ldFee = 0
        'End If
        
        objCmd.CommandText = "Select sum(fee_amnt) from fees Where crs_id = '" & lsCourseId & "' "
        ldFee += CDbl("0" & objCmd.ExecuteScalar())
        
        objCmd.CommandText = "Select Sum(fee_amnt) from feessec where sid = '" & lsSid & "'"
        lsFeeSec = objCmd.ExecuteScalar()
        If Not IsDBNull(lsFeeSec) Then
            ldFee += CDbl(lsFeeSec)
        End If
        
        Response.Write(ldFee.ToString() & "|")
        
        Response.Write(Session("section_" & Request("index")) & "|")
        
    End If
    Session("hs_course_" & Request("index")) = Request("hs_course")
    
%>
<!-- #INCLUDE FILE="DBClose.aspx" -->