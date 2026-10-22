<!-- #INCLUDE FILE="DBConn.aspx" -->
<%
    Dim liLoop As Integer
    Dim objCmd As SqlClient.SqlCommand = Session("dbConn").CreateCommand()
    Dim rsData As SqlClient.SqlDataReader
%>
<style>
    td {
        padding:4px;
    }

    .smallbox td {
        padding:1px;
    }

    .maintable td {
        padding:4px;
        border:1px solid #002a64;
        font-size:11pt;
        vertical-align:top;
    }

@media print
{    
    .no-print, .no-print *
    {
        display: none !important;
    }
}
</style>

<script type="text/javascript">
    $(document).ready(function () {
        setTimeout('window.prit()', 100);
    });
</script>
<br />
<center>
    <table style="height:75px;width:900px;">
        <tr>
            <td style="vertical-align:top;width:33%;text-align:left;"><img src="images/logo.png" /></td>
            <td style="width:33%;">&nbsp;</td>
            <td style="vertical-align:top;width:33%;text-align:right;">
                <table class="smallbox" style="border:2px solid black;font-size:8pt;padding:3px;display:inline-block;">
                    <tr><td>Tuition Paid ___________</td></tr>
                    <tr><td>Textbook Rec'd ___________</td></tr>
                    <tr><td>Textbooks Amt Paid ___________</td></tr>
                    <tr><td>Initials ___________</td></tr>
                </table>
            </td>
        </tr>
    </table>
  				
<center>
    <table style="height:50px;width:900px;">
        <tr>
            <td style="vertical-align:top;font-weight:bold;font-size:18pt;text-align:Center;">Concurrent HS Enrollment Request</td>  
		    </td>
       </tr>
</table>	
			                  
<table class="no-print" style="height: 50px;width:500px;">	
		<tr>
			<td style="vertical-align:top;width:33%;text-align:right;"><img src="images/right arrow - web.png" /></td>
			<td style="vertical-align:top;width:33%;text-align:center;">
                <input type="button" onClick="window.print()" value="Print This Page!"/>
            </td>
			<td style="vertical-align:top;width:33%;text-align:left;"><img src="images/left arrow - web.png" /></td>
</table>	

		<table>
            <tr>
                					
				 <center>
                        <mark {background-color: yellow;}><U><i>This form must be printed off, signed, and turned into your counselor.</u></i></mark> <br />
                 </center>
			</tr>
    </table>	
<hr>
        
		<table>
            <tr>
                <td style="font-weight:bold;">First Name</td>
                <td><%=Session("first_name")%></td>
                <td style="font-weight:bold;">Last Name</td>
                <td><%=Session("last_name")%></td>
                <td style="font-weight:bold;">Last 4 Digits of SSN</td>
                <td><%=Session("ssn")%></td>
            </tr>
            <tr>
                <td colspan="6">
                    <br />
            <center>
            <table class="maintable" style="border-collapse:collapse;">
            <tr>
                <td>HS Course Name</td>
                <td>Course Name</td>
                <td>Course #</td>
                <td>Semester</td>
                <td>Section</td>
                <td>Faculty</td>
                <td>Location</td>
                <td>Memo</td>
                <td>Credit Hrs</td>
                <td>Cost</td>
            </tr>
            <%
                For liLoop = 1 To Session("NumCourses")
                    If Not Session("Deleted_Courses").ToString().Contains(" " & liLoop.ToString() & " ") Then
                        If IsNumeric(Request("hs_course_" & liLoop)) Then
                            objCmd.CommandText = "Insert Into web_enroll (first_name, last_name, ssn, camp_cod, hs_course, term_semester, term_year, section, cost) values ("
                            objCmd.CommandText &= "'" & Session("first_Name") & "', "
                            objCmd.CommandText &= "'" & Session("last_name") & "', "
                            objCmd.CommandText &= "'" & Session("ssn") & "', "
                            objCmd.CommandText &= "'" & Session("camp_cod") & "', "
                            objCmd.CommandText &= Session("hs_course_" & liLoop) & ", "
                            objCmd.CommandText &= "'" & Session("term_semester") & "', "
                            objCmd.CommandText &= "'" & Session("term_year") & "', "
                            objCmd.CommandText &= "'" & Request("section_" & liLoop) & "', "
                            objCmd.CommandText &= Request("cost_" & liLoop) & ") "
                            objCmd.ExecuteNonQuery()
                    
                    %>
            <tr>
                <td>
                    <%
                        objCmd.CommandText = "Select camp_course_name from campus_course Where UID = " & Session("hs_course_" & liLoop)
                        rsData = objCmd.ExecuteReader
                        If rsData.Read Then
                            Response.Write(Trim(rsData("camp_course_name")))
                        End If
                        rsData.Close()
                    %>
                </td>
                <td><%=Request("course_name_" & liLoop)%></td>
                <td><%=Request.Form("course_num_" & liLoop)%></td>
                <td><%=Request("semester_" & liLoop)%></td>
                <td><%=Request("section_" & liLoop)%></td>
                <td><%=Request("faculty_" & liLoop)%></td>
                <td><%=Request("location_" & liLoop)%></td>
                <td><%=Request("time_" & liLoop)%></td>
                <td style="text-align:right;"><%=Request("credit_hours_" & liLoop)%></td>
                <td style="text-align:right;"><%=Request("cost_" & liLoop)%></td>
            </tr>
                    <%
                    End If
                End If
            Next
            %>
            <tr>
                <td colspan="8" style="text-align:left;border:none;">&nbsp;</td>
                <td style="border:none;text-align:right;">Total</td>
                <td style="border:none;text-align:right;"><%=Request("total_cost")%></td>
            </tr>
        </table>
            </center>
                </td>
            </tr>
            <tr>
                <td colspan="6">
                    <table style="border: 1px solid black;width:900px;">
                        <tr>
                            <td style="text-align:center;font-weight:bold;">
                                TO BE SIGNED BY THE STUDENT <u>and</u> PARENT
                            </td>
                        </tr>
                        <tr>
                            <td style="font-size:11pt;">
                                I certify that the information that I have completed on this form is correct. I also understand that there are minimum assessment and program standards that I must adhere to in order to be accepted and remain in the concurrent program at SATC. Failure on my part to maintain minimum performance standards and comply with College program requirements may result in my dismissal from the program. I hereby authorize SATC to share personal information including grades and attendance with the high school and my parents.
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Student Signature ______________________________________&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date ______________________________<br /><br />
                                Parent Signature _______________________________________&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date ______________________________
                            </td>
                        </tr>
                    </table>
                    <br /><br />
                    <center>
                        A current high school transcript must be submitted that documents that the minimum GPA requirement has been met.<br />
                        (2.5 GPA for Technical Coursework and 2.75 for Academic Coursework) GPA ___________ H.S. Counselor ___________
                    </center>
                    <br />
                    <table style="border: 2px solid black;width:900px;">
                        <tr>
                            <td style="text-align:center;font-weight:bold;">
                                TO BE COMPLETED BY THE HIGH SCHOOL PRINCIPAL
                            </td>
                        </tr>
                        <tr>
                            <td style="font-size:11pt;">
                                I certify that the above-named student is enrolled as at least a high school sophomore, or is certified as "gifted" with an IEP (copy must be attached) that specifies college study, and has permission to enroll at Salina Area Technical College for college credit during the 20___ - 20___ academic year.  I understand that failure by the student to comply with College and program requirements may result in student dismissal from the concurrent program.<br />
                                Signature of High School Principal _____________________________________ Date ________________
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

        <br />

</center>
<br />
<!-- #INCLUDE FILE="DBClose.aspx" -->