<!-- #INCLUDE FILE="Header.aspx" -->
<style>
    td {
        padding:4px;
    }
</style>
<script type="text/javascript">
    function formValidate() {
        if ($("#first_name").val() == '' || $("#last_name").val() == '' || $("#ssn").val() == '' ) { //|| $("#camp_cod").val() == '') {
            alert('Please complete all fields before continuing.');
            return false;
        }
        return true;
    }
</script>

<br />
<center>
    <strong>Record Found</strong>
    <form method="post" action="Enroll2.aspx" name="frmEnroll" onsubmit="return formValidate()">
        <table>
            <tr>
                <td>First Name</td>
                <td><input readonly="readonly" type="text" name="first_name" id="first_name" style="width:247px;" value="<%=Session("first_name")%>" /></td>
            </tr>
            <tr>
                <td>Last Name</td>
                <td><input readonly="readonly" type="text" name="last_name" id="last_name" style="width:247px;" value="<%=Session("last_name")%>" /></td>
            </tr>
            <tr>
                <td>Last 4 Digits of SSN</td>
                <td><input readonly="readonly" type="text" name="ssn" id="ssn" maxlength="4" style="width:247px;" value="<%=Session("ssn")%>" onkeypress="return event.charCode >= 48 && event.charCode <= 57" /></td>
            </tr>
            <tr style="display:none;">
                <td>Program</td>
                <td>
                    <select id="dept_cod" name="dept_cod" style="width:250px;">
                        <option value=""></option>
                        <%
                            objCmd.CommandText = "Select dept_cod, dept_txt from dept Where exclude_outside = 0"
                            rsData = objCmd.ExecuteReader
                            While rsData.Read
                            %>
                                <option <%If Session("dept_cod") = Trim(rsData("dept_cod")) Then Response.Write(" selected=""selected"" ")%> value="<%=Trim(rsData("dept_cod"))%>"><%=Trim(rsData("dept_txt"))%></option>
                            <%
                            End While
                            rsData.Close()
                        %>
                    </select>
                </td>
            </tr>
            <tr  style="display:none;">
                <td>Term</td>
                <td>
                    <select id="term" name="_term" style="width:250px;">
                        <option value=""></option>
                        <%
                            objCmd.CommandText = "SELECT DISTINCT RTRIM(semester.sm_desc) + ' ' + RTRIM(crssect.sch_yr) AS Semester FROM crssect "
                            objCmd.CommandText &= "INNER JOIN semester ON semester.semester = crssect.semester WHERE crssect.cancel = 0 AND crssect.end_dt > GETDATE()"
                            rsData = objCmd.ExecuteReader
                            While rsData.Read
                            %>
                                <option <%If Session("term") = Trim(rsData("Semester")) Then Response.Write(" selected=""selected"" ")%> value="<%=Trim(rsData("Semester"))%>"><%=Trim(rsData("Semester"))%></option>
                            <%
                            End While
                            rsData.Close()
                         %>
                        <option selected="selected" value="Spring 202627"></option>
                    </select>
                </td>                
            </tr>
            <tr style="display:none;">
                <td>Location</td>
                <td>
                    <select id="camp_cod" name="camp_cod" style="width:250px;">
                        <option value=""></option>
                        <%
                            objCmd.CommandText = "SELECT DISTINCT crssect.camp_cod, campus.camp_txt FROM crssect "
                            objCmd.CommandText &= "INNER JOIN campus on campus.camp_cod = crssect.camp_cod "
                            objCmd.CommandText &= "WHERE crssect.cancel = 0 AND crssect.end_dt > GETDATE() "
                            'objCmd.CommandText &= "And campus.camp_cod in (Select distinct camp_cod from campus_course) "
                            rsData = objCmd.ExecuteReader
                            While rsData.Read
                                If Trim(rsData("camp_cod")) = "ONL" Then
                                    %>
                                    <option <%If Session("camp_cod") = Trim(rsData("camp_cod")) Then Response.Write(" selected=""selected"" ")%> value="<%=Trim(rsData("camp_cod"))%>">Other/Online</option>
                                    <%
                                Else
                                    %>
                                    <option <%If Session("camp_cod") = Trim(rsData("camp_cod")) Then Response.Write(" selected=""selected"" ")%> value="<%=Trim(rsData("camp_cod"))%>"><%=Trim(rsData("camp_txt"))%></option>
                                    <%
                                End If
                                %>
                            <%
                            End While
                            rsData.Close()
                         %>
                        
                    </select>
                </td>
            </tr>
            <tr style="display:none;">
                <td>Level</td>
                <td>
                    <select name="div_cod" id="div_cod" style="width:250px;" disabled="disabled">
                        <option <%If Session("div_cod") = "PT" Then Response.Write(" selected=""selected"" ")%> value="PT">Part Time</option>
                        <option <%If Session("div_cod") = "FT" Then Response.Write(" selected=""selected"" ")%> value="FT">Full Time</option>
                    </select>
                </td>
            </tr>
        </table>

        <br />
        <div style="width:100%;text-align:center;">
	    <input type="button" name="cmdReset" class="round-button" style="width:125px" onclick="location.href='Logout.aspx'" value="<< Start Over" />&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="submit" name="cmdNext" class="round-button" style="width:125px" value="Continue >>" />
        </div>
        <input type="hidden" name="term" value="Spring 202627" />
    </form>
</center>
<br />
<!-- #INCLUDE FILE="Footer.aspx" -->