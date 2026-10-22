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
        setTimeout('window.print()', 100);
    });
</script>
<br />


<center>
    <table style="height:50px;width:900px;">
        <tr>
            <td style="vertical-align:top;width:50%;text-align:left;"><img src="images/logo.png" /></td>
                        <td style="vertical-align:middle;width:50%;text-align:center;font-weight:bold;font-size:18pt;text-align:Center;">Spring HS Course Enrollment Request</td>  
                
            </td>
        </tr>
    </table>
  				
<center>
    	
			                  
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
                        <mark {background-color: yellow;}> <u> This form must be printed, signed, and turned in to your counselor.</u></mark> <br />
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
                <td>Location</td>
                <td>Course Name</td>
                <td>Course #</td>
                <td>Semester</td>
                <td>Section</td>
                <td>Faculty</td>
                <td>Memo</td>
                <td>Credit Hrs</td>
                <td>Cost</td>
            </tr>
            <%
                For liLoop = 1 To Session("NumCourses")
                    If Not Session("Deleted_Courses").ToString().Contains(" " & liLoop.ToString() & " ") Then
                        If IsNumeric(Request("hs_course_" & liLoop)) Then
                            objCmd.CommandText = "Insert Into web_enroll (first_name, last_name, ssn, camp_cod, hs_course, crs_id, term_semester, term_year, section, cost) values ("
                            objCmd.CommandText &= "'" & Session("first_Name") & "', "
                            objCmd.CommandText &= "'" & Session("last_name") & "', "
                            objCmd.CommandText &= "'" & Session("ssn") & "', "
                            objCmd.CommandText &= "'" & Session("campus" & liLoop) & "', "
                            objCmd.CommandText &= 0 & ", "
                            objCmd.CommandText &= Session("hs_course_" & liLoop) & ", "
                            objCmd.CommandText &= "'" & Session("term_semester") & "', "
                            objCmd.CommandText &= "'" & Session("term_year") & "', "
                            objCmd.CommandText &= "'" & Request("section_" & liLoop) & "', "
                            objCmd.CommandText &= Request("cost_" & liLoop) & ") "
                            objCmd.ExecuteNonQuery()
                    
                    %>
            <tr>
                <td><%=Request("campus" & liLoop)%></td>
                <td>
                    <%
                        objCmd.CommandText = "Select crs_txt from course Where crs_id = " & Session("hs_course_" & liLoop)
                        rsData = objCmd.ExecuteReader
                        If rsData.Read Then
                            Response.Write(Trim(rsData("crs_txt")))
                        End If
                        rsData.Close()
                    %>
                </td>
                <td><%=Request.Form("course_num_" & liLoop)%></td>
                <td><%=Request("semester_" & liLoop)%></td>
                <td><%=Request("section_" & liLoop)%></td>
                <td><%=Request("faculty_" & liLoop)%></td>
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
                <td colspan="7" style="text-align:left;border:none;">&nbsp;</td>
                <td style="border:none;text-align:right;">Total</td>
                <td style="border:none;text-align:right;"><%=Request("total_cost")%></td>
            </tr>
        </table>
            </center>
                </td>
            </tr>
            <tr>
			
			
	<table class="smallbox" style="height:80px;width:900px;">
        <tr>
            <td style="vertical-align:top;width:45%;text-align:left;">
				<b><center>Payment Options</b><br/></center>
           		Students will have up to <b>seven business days after the first day of high school </b>to pay half of the total bill. The remaining amount is due November 20th for the Fall semester and April 20th for the Spring semester. If payment is not received or a payment plan has not been requested, the student will be unenrolled in the course.<br/><br/>
                Students will be billed after enrollment is complete. Payment will be due according to the date on the bill.<b> If you have a previous account balance, you will not be able to enroll into future semesters.</b><br/><br/>
                To qualify for the following payment plan - a student must have a minimum <b>semester</b> balance of $200 to qualify. Payment dates will reflect on enrollment form when printed.<br/><br/>
                Payments may be made directly to SATC by mail ATTN: Janie Klaus, 2562 Centennial Road, Salina, KS 67401, by phone at 785-309-3100, or online as per instructions on enrollment form.
          	</td>
        </tr>
    </table>
    <%-- 
		   		<table class="smallbox" style="width:350px;">			
						<tr style="text-align:center">
							<th>Fall Due Date</th>
							<th>% of Balance Due</th> 
                            <th>Spring Due Date</th>
							<th>% of Balance Due</th>
						</tr>
						<tr style="text-align:center">
							<td>Sep 1st</td>
							<td>50%</td>
                            <td>Feb 20th</td>
							<td>50%</td>
						</tr>
						<tr style="text-align:center">
							<td>Oct 1st</td>
							<td>75%</td>
                            <td>Mar 20th</td>
							<td>75%</td>
						</tr>
						<tr style="text-align:center">
							<td>Nov 1st</td>
							<td>100%</td>
                            <td>Apr 20th</td>
							<td>100%</td>
						</tr>
				</table>
     --%>   
   <%-- <td style="vertical-align:top;width:55%;text-align:left;">
				<br/><br/><br/><b><center>Important Dates</b><br/></center>
				&nbsp;&nbsp;- Last Day to Drop for 100% Refund* - 7 Days after class has started<br/>
				&nbsp;&nbsp;- Last Day to Drop for 50% Refund* - 12 Days after class has started<br/>
				&nbsp;&nbsp;- Last Day to withdraw with no transcript - 20 Days after class has started<br/>
				&nbsp;&nbsp;- Last Day to withdraw with a W - 12 weeks after class has started<br/>
			
			</td> --%>
		<table>
            <tr> 
                <th>
                    <td>
                        <table class="smallbox" style="width:350px;">			
						        <tr style="text-align:center">
							        <th>Fall Due Date</th>
							        <th>% of Balance Due</th> 
                                    <th>Spring Due Date</th>
							        <th>% of Balance Due</th>
						        </tr>
						        <tr style="text-align:center">
							        <td>Sep 1st</td>
							        <td>50%</td>
                                    <td>Feb 20th</td>
							        <td>50%</td>
						        </tr>
						        <tr style="text-align:center">
							        <td>Oct 1st</td>
							        <td>75%</td>
                                    <td>Mar 20th</td>
							        <td>75%</td>
						        </tr>
						        <tr style="text-align:center">
							        <td>Nov 1st</td>
							        <td>100%</td>
                                    <td>Apr 20th</td>
							        <td>100%</td>
						        </tr>
				        </table>
                    </td>
                    <td>
                        <b><center>Important Dates</b><br/></center>
				        &nbsp;&nbsp;- Last Day to Drop for 100% Refund* - 7 Days after class has started<br/>
				        &nbsp;&nbsp;- Last Day to Drop for 50% Refund* - 12 Days after class has started<br/>
				        &nbsp;&nbsp;- Last Day to withdraw with no transcript - 20 Days after class has started<br/>
				        &nbsp;&nbsp;- Last Day to withdraw with a W - 12 weeks after class has started<br/></tr>
                    </td>   	        
                </th>
            </tr>
	</table>
			
						
			<tr>
                <td colspan="6">
                    <table style="width:900px;">	
					 <tr>
                        <td style="text-align:left; font-size: 9pt;">
                                I certify that the information that I have completed on this form is correct. I also understand that there are minimum assessment and program standards that I must adhere to in order to be accepted and remain in the concurrent program at SATC. Failure on my part to maintain minimum performance standards and comply with College program requirements may result in my dismissal from the program.
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
                        <i>(2.5 GPA for Technical Coursework and 2.5 for Academic Coursework)</i> <br/>
						<br/>
						GPA ___________ &nbsp;&nbsp;State Assessment Score ___________ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i>Other (Test & Score) __________________ </i> <br/>
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
				<table style="width:900px;">
					<td style="font-size:8pt;" >
					<center>
                        Salina Area Technical College does not discriminate on the basis of race, religion, color, sex (including pregnancy and gender identity), sexual orientation, parental status, national origin, age, disability, family medical history or genetic information, military service, or any other non-merit based factor in admission or access to, or treatment or employment in, its programs and activities. Any person having inquiries concerning compliance with the regulations implementing Title VI, Title VII, ADA, Title IX, Section 504, Title II, GINA, is directed to contact the Human Resources Specialist, 2562 Centennial Rd, Salina, KS 67401, 785-309-3100. <br/>	
					</td>
				</table>
					
					
                </td>
            </tr>
        </table>
<% Session.Abandon() %>
     <!--  <br /> -->

<!---
<p style="page-break-before: always;">

<center>
    <table style="height:50px;width:900px;">
        <tr>
            <td style="vertical-align:top;width:100%;text-align:midle;">
		<center>
		<img src="images/ferpa.png" />
		</center>
	    </td>
        </tr>
    </table>
</center>
    <table style="height:50px;width:900px;">
            <tr>
                <td style="font-weight:bold;">First Name</td>
                <td><%=Session("first_name")%></td>
                <td style="font-weight:bold;">Last Name</td>
                <td><%=Session("last_name")%></td>
                <td style="font-weight:bold;">DOB(MM/DD/YYYY)</td>
                <td><%=Session("DOB")%></td>
            </tr>
    </table>


<table style="height:50px;width:900px;">
<tr>
<td>
<center>
<img src="images/ferpa_form_new.png" style="width:900px;" />
</center>
</td>
</tr>
</table>


	<table style="width:900px;">
		<td style="font-size:8pt;" >
                Salina Area Technical College does not discriminate on the basis of race, religion, color, sex (including pregnancy and gender identity), sexual orientation, parental status, national origin, age,
disability, family medical history or genetic information, military service, or any other non-merit based factor in admission to or access to, or treatment or employment in, its programs and
activities. Any person having inquiries concerning compliance with the regulations implementing Title VI, Title VII, ADA, Title IX, Section 504, Title II, GINA, is directed to contact the Human
Resources Specialist, 2562 Centennial Rd, Salina, KS 67401, 785-309-3100.<br/>	<br />

For more information about our completion, on-time graduation rates, cost, placement rates, and median debt incurred, please go to <a href="http://www.salinatech.edu/">http://www.salinatech.edu/</a> and search by program of
study.
		</td>
	</table>  				

   	

</p>



</center>

<br />
-->
<!--
<% Session.Abandon() %>
 #INCLUDE FILE="DBClose.aspx" -->