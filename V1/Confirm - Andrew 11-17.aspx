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
                        <mark {background-color: yellow;}> <u> This form must be printed off, signed, and turned in to your counselor.</u></mark> <br />
                 </center>
					<br/>
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
			
			
	<table style="height:80px;width:900px;">
        <tr>
            <td style="vertical-align:top;width:45%;text-align:left;">
				<b><center>Payment Options</b><br/></center>
           		Students <u>MUST</u> have a semester total of <u> at least</u> $300 to qualify for the below payment plan.  Students with a semester total less than $300 must pay in full before course(s) begin.<br/><br/>
					<table style="width:350px;">			
						<tr style="text-align:center">
							<th>Due Date</th>
							<th>% of Balance Due</th> 
						</tr>
						<tr style="text-align:center">
							<td>January 1st</td>
							<td>25%</td>
						</tr>
						<tr style="text-align:center">
							<td>February 1st</td>
							<td>50%</td>
						</tr>
						<tr style="text-align:center">
							<td>March 1st</td>
							<td>75%</td>
						</tr>
						<tr style="text-align:center">
							<td>April 1st</td>
							<td>100%</td>
						</tr>
					</table>	
			</td>
		   	   
		    <td style="vertical-align:top;width:55%;text-align:left;">
				<br/><br/><br/><b><center>Important Dates</b><br/></center>
				&nbsp;&nbsp;- Last Day to Drop for 100% Refund* - 7 Days after class has started<br/>
				&nbsp;&nbsp;- Last Day to Drop for 50% Refund* - 12 Days after class has started<br/>
				&nbsp;&nbsp;- Last Day to withdraw with no transcript - 20 Days after class has started<br/>
				&nbsp;&nbsp;- Last Day to withdraw with a W - 12 weeks after class has started<br/>
			
			</td>
			
			
		</tr>
	</table>
			
						
			<tr>
                <td colspan="6">
                    <table style="width:900px;">	
					 <tr>
                        <td style="text-align:left;">
                                I certify that the information that I have completed on this form is correct. I also understand that there are minimum assessment and program standards that I must adhere to in order to be accepted and remain in the concurrent program at SATC. Failure on my part to maintain minimum performance standards and comply with College program requirements may result in my dismissal from the program. I hereby authorize SATC to share personal information including grades and attendance with the high school and my parents.
                        </td>
							

                        <tr>
                            <td> <center>
                                Student Signature ______________________________________&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date ______________________________<br /><br />
                                Parent Signature _______________________________________&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date ______________________________
                            </center>
							</td>
                        </tr>
                    </table>
                    
					<br/><hr>
                    <center>
                        <b>TO BE COMPLETED BY THE HIGH SCHOOL </b>
					
				<table style="width:900px;">
					<td>
					<center>
                        A current high school transcript and KAP score must be submitted that documents that the minimum requirements have been met.  A student may also use ACT, SAT, Accuplacer, or Compass scores in place of a KAP score.
                        <i>(2.5 GPA for Technical Coursework and 2.75 for Academic Coursework)</i> <br/>
						<br/>
						GPA ___________ &nbsp;&nbsp;KAP Score ___________ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>Other (Test & Score) __________________ </i> <br/>
						<br/>
						HS Counselor Name (print) _____________________________  Signature ______________________________ <br/> <br/>
                    </center>
					</td>
                    <br />
				</table>
                    <table style="border: 2px solid black;width:800px;">
                        <tr>
                            <td style="text-align:center;font-weight:bold;">
                                TO BE COMPLETED BY THE HIGH SCHOOL PRINCIPAL
                            </td>
                        </tr>
                        <tr>
                            <td style="font-size:11pt;">
                                I certify that the above-named student is enrolled as at least a high school sophomore, or is certified as "gifted" with an IEP (copy must be attached) that specifies college study, and has permission to enroll at Salina Area Technical College for college credit.  I understand that failure by the student to comply with College and program requirements may result in student dismissal from the concurrent program.<br /> <br/>
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