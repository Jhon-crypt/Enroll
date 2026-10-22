<!-- #INCLUDE FILE="Header.aspx" -->
<%
    Dim liCourses As Integer = 0
    Dim liLoop As Integer = 0
    Dim liLoop2 As Integer = 0
    Dim lsSel As String = ""
    Dim lsData() As String
    Dim liSections As Integer = 1
    Dim lsName As String = ""
    
    If IsNothing(Session("Deleted_Courses")) Then
        Session("Deleted_Courses") = ""
    End If
    
    If IsNothing(Session("NumCourses")) Then
        liCourses = 1
        Session("NumCourses") = 1
    ElseIf Session("NumCourses").ToString() = "" Then
        liCourses = 1
        Session("NumCourses") = 1
    Else
        liCourses = CInt(Session("NumCourses"))
    End If
    
    If Request("cmdNext") > "" Then
        Session("first_name") = Request("first_name")
        Session("last_name") = Request("last_name")
        Session("ssn") = Request("ssn")
        Session("dept_cod") = Request("dept_cod")
        Session("term") = Request("term")
        Session("camp_cod") = Request("camp_cod")
        Session("div_cod") = Request("div_cod")
        
        If Session("term") > "" Then
            lsData = Split(Session("term"), " ")
            objCmd.CommandText = "Select semester from semester where sm_desc = '" & lsData(0) & "' "
            rsData = objCmd.ExecuteReader
            If rsData.Read Then
                Session("term_semester") = Trim(rsData("semester"))
            End If
            rsData.Close()
            Session("term_year") = lsData(1)
        End If
        
        If Session("camp_cod") > "" Then
            objCmd.CommandText = "Select camp_txt from campus where camp_cod = '" & Session("camp_cod") & "' "
            Session("camp_txt") = Trim(objCmd.ExecuteScalar() & "")
        End If
    End If

    
   
%>
<style>
    .maintable td {
        padding:4px;
        border:1px solid #002a64;
        font-size:12pt;
        vertical-align:top;
    }
</style>
<script type="text/javascript">
    var lsSection

    function setSection(index) {
        $.ajax({ type: "POST", url: "Course_Lookup.aspx?mode=sec&sec=" + $("#section_" + index).val() + "&hs_course=" + $("#hs_course_" + index).val() + "&index=" + index, async: false });
        lookupCourse(index);
    }

    function lookupCourse(index) {
        var lsName
        var lsNum
        var lsDept
        var lsCredits
        var lcPrice
        var lsFac
        var lsLoc
        var lsTime
        var lsSemester
        var lsOnline

        if ($("#hs_course_" + index).val() == 'delete') {
            var lsPage = '<%=Request("SCRIPT_NAME")%>';
            location.href= "Delete_Course.aspx?Refer=" + lsPage + "&Course=" + index;
            return;
        }

        if ($("#hs_course_" + index + " option:selected").text().indexOf('(Online)') != -1) {
            lsOnline = '1';
        }
        else {
            lsOnline = '0';
        }

        if ($("#hs_course_" + index).val() == '') {
            $("#course_name_" + index).html('');
            $("#course_num_" + index).html('');
            $("#semester_" + index).html('');
            $("#faculty_" + index).html('');
            $("#location_" + index).html('');
            $("#time_" + index).html('');
            $("#credit_hours_" + index).html('');
            $("#cost_" + index).html('');

            $("#t_course_num_" + index).val('');
            $("#t_semester_" + index).val('');
            $("#t_section_" + index).val('');
            $("#t_faculty_" + index).val('');
            $("#t_location_" + index).val('');
            $("#t_time_" + index).val('');
            $("#t_credit_hours_" + index).val('');
            $("#t_cost_" + index).val('');

            $.ajax({ type: "POST", url: "Course_Lookup.aspx?hs_course=&index=" + index, async: false });
            doTotals();
            return false;
        }
        $.ajax({ type: "POST", url: "Course_Lookup.aspx?hs_course=" + $("#hs_course_" + index).val() + "&index=" + index + "&Section=" + $("#section_" + index).val() + "&Online=" + lsOnline, async: false }).done(function (data) {
            var iIndex = data.indexOf('COURSE_RESPONSE');
            if (iIndex != -1) {
                if (data.substr(iIndex + 15) != '') {
                    data = data.substr(iIndex + 15);
                    iIndex = data.indexOf('|');
                    lsName = data.substr(0, iIndex);
                    data = data.substr(iIndex + 1);
                    iIndex = data.indexOf('|');
                    lsNum = data.substr(0, iIndex);
                    data = data.substr(iIndex + 1);
                    iIndex = data.indexOf('|');
                    lsDept = data.substr(0, iIndex);
                    data = data.substr(iIndex + 1);
                    iIndex = data.indexOf('|');
                    lsCredits = data.substr(0, iIndex);
                    data = data.substr(iIndex + 1);
                    iIndex = data.indexOf('|');
                    lcPrice = data.substr(0, iIndex);
                    data = data.substr(iIndex + 1);
                    iIndex = data.indexOf('|');
                    lsSemester = data.substr(0, iIndex);
                    data = data.substr(iIndex + 1);
                    iIndex = data.indexOf('|');
                    lsLoc = data.substr(0, iIndex);
                    data = data.substr(iIndex + 1);
                    iIndex = data.indexOf('|');
                    lsTime = data.substr(0, iIndex);
                    data = data.substr(iIndex + 1);
                    iIndex = data.indexOf('|');
                    lsFac = data.substr(0, iIndex);
                    data = data.substr(iIndex + 1);
                    iIndex = data.indexOf('|');
                    lsFee = data.substr(0, iIndex);
                    data = data.substr(iIndex + 1);
                    iIndex = data.indexOf('|');
                    lsSection = data.substr(0, iIndex);

                    $("#course_name_" + index).html(lsName);
                    $("#course_num_" + index).html(lsNum);
                    $("#semester_" + index).html(lsSemester);
                    $("#faculty_" + index).html(lsFac);
                    $("#credit_hours_" + index).html(lsCredits);
                    $("#cost_" + index).html(formatCurrency(lsFee));
                    $("#location_" + index).html(lsLoc);
                    $("#time_" + index).html(lsTime);
                    
                    $("#t_course_name_" + index).val(lsName);
                    $("#t_course_num_" + index).val(lsNum);
                    $("#t_semester_" + index).val(lsSemester);
                    $("#t_faculty_" + index).val(lsFac);
                    $("#t_credit_hours_" + index).val(lsCredits);
                    $("#t_cost_" + index).val(formatCurrency(lsFee));
                    $("#t_location_" + index).val(lsLoc);
                    $("#t_time_" + index).val(lsTime);
                }
            }
        });
        doTotals();

        var lsSel = $("#hs_course_" + index + " option:selected").text();
        var liSec = (lsSel.length - trim(lsSel).length) + 1;
        $('#section_' + index).html('<option value="1">Section 1</option>');
        for (var i=2; i<=liSec; i++) {
            $('#section_' + index).append($('<option>', {
                value: i,
                text: 'Section ' + i
            }));
        }

        $("#section_" + index).val(lsSection);

    }

    $(document).ready(function () {
        $(".course").each(function () {
            lookupCourse($(this).attr('id').replace('hs_course_', ''));
        });
        
    });

    function addCourse() {
        var lsPage = '<%=Request("SCRIPT_NAME")%>';
        $("#frmEnroll2").attr("action", "Add_Course.aspx?Refer=" + lsPage);
        $("#frmEnroll2").submit();
    }

    function doTotals() {
        var ldTotal = 0;

        $(".cost").each(function () {
            if (NumbersOnlyA($(this).html()) != '') {
                ldTotal += eval(NumbersOnlyA($(this).html()));
            }
        });
        $("#total_cost").html(formatCurrency(ldTotal));
        $("#t_total_cost").val(formatCurrency(ldTotal));
    }
</script>
<br />
<center>
    <form method="post" id="frmEnroll2" action="Confirm.aspx">
        <input type="hidden" id="numCourses" name="numCourses" value="<%=liCourses%>" />
        <table class="maintable" style="border-collapse:collapse;">
            <tr>
                <td>HS Course Name</td>
                <td>SATC Course Name</td>
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
                For liLoop = 1 To liCourses
                    If Not Session("Deleted_Courses").ToString().Contains(" " & liLoop.ToString() & " ") Then
                    %>
            <tr>
                <td>
                    <select class="course" name="hs_course_<%=liLoop%>" id="hs_course_<%=liLoop%>" onchange="lookupCourse(<%=liLoop%>)">
                        <option value="">Select a course</option>
                        <%If liLoop <> 1 Then%>
                            <option value="delete">Delete Line</option>
                        <%End If%>
                        <%
                            objCmd.CommandText = "Select course.crs_id as UID, COALESCE(campus_course.camp_course_name, crs_txt) as camp_course_name, Max(section) as sections "
                            objCmd.CommandText &= ",crssect.camp_cod From course Left Join campus_course on campus_course.course = course.course "
                            objCmd.CommandText &= "Inner Join crssect on crssect.crs_id = course.crs_id And crssect.sch_yr = '" & Session("term_year") & "' "
                            objCmd.CommandText &= "And crssect.semester = '" & Session("term_semester") & "' And crssect.camp_cod In ('" & Session("camp_cod") & "','ONL') "
                            objCmd.CommandText &= "And crssect.cancel = 0  "
                            objCmd.CommandText &= "Group By course.crs_id, crssect.camp_cod, COALESCE(campus_course.camp_course_name, crs_txt) Order By COALESCE(campus_course.camp_course_name, crs_txt) "
                            rsData = objCmd.ExecuteReader
                            While rsData.Read
                                If Trim(Session("hs_course_" & liLoop) & "").ToString() = Trim(rsData("UID")).ToString() Then
                                    lsSel = " selected=""selected"" "
                                Else
                                    lsSel = ""
                                End If
                                If Trim(rsData("camp_cod")).ToUpper() = "ONL" Then
                                    lsName = Trim(rsData("camp_course_name")) & " (Online)"
                                Else
                                    lsName = Trim(rsData("camp_course_name"))
                                End If
                                If rsData("sections").ToString() <> "1" Then
                                    liSections = CInt(rsData("sections"))
                                    %>
                                    <option <%=lsSel%> value="<%=Trim(rsData("UID"))%>"><%=lsName & Space(liSections - 1)%></option>
                                    <%
                                Else
                                    %>
                                    <option <%=lsSel%> value="<%=Trim(rsData("UID"))%>"><%=lsName%></option>
                                    <%                                    
                                End If
                            End While
                            rsData.Close()
                        %>
                    </select>
                </td>
                <td><a id="course_name_<%=liLoop%>"></a><input type="hidden" name="course_name_<%=liLoop%>" id="t_course_name_<%=liLoop%>" value="" /></td>
                <td><a id="course_num_<%=liLoop%>"></a><input type="hidden" name="course_num_<%=liLoop%>" id="t_course_num_<%=liLoop%>" /></td>
                <td><a id="semester_<%=liLoop%>"></a><input type="hidden" name="semester_<%=liLoop%>" id="t_semester_<%=liLoop%>" /></td>
                <td>
                    <select id="section_<%=liLoop%>" name="section_<%=liLoop%>" onchange="setSection(<%=liLoop%>)">
                        <option value="1">Section 1</option>
                    </select>
                </td>
                <td><a id="faculty_<%=liLoop%>"></a><input type="hidden" name="faculty_<%=liLoop%>" id="t_faculty_<%=liLoop%>" /></td>
                <td><a id="location_<%=liLoop%>"><%=Session("camp_txt")%></a><input type="hidden" name="location_<%=liLoop%>" id="t_location_<%=liLoop%>" /></td>
                <td><a id="time_<%=liLoop%>"></a><input type="hidden" name="time_<%=liLoop%>" id="t_time_<%=liLoop%>" /></td>
                <td style="text-align:right;"><a class="credits" id="credit_hours_<%=liLoop%>"></a><input type="hidden" name="credit_hours_<%=liLoop%>" id="t_credit_hours_<%=liLoop%>" /></td>
                <td style="text-align:right;"><a class="cost" id="cost_<%=liLoop%>"></a><input type="hidden" name="cost_<%=liLoop%>" id="t_cost_<%=liLoop%>" /></td>
            </tr>
                    <%
                    End If
                Next
            %>
            <tr>
                <td colspan="8" style="text-align:left;border:none;"><a class="round-button" onclick="addCourse()" style="cursor:pointer;font-size:10pt;width:200px;height:30px;padding-top:5px;padding-bottom:5px;display:inline;">Add Another Course</a></td>
                <td style="border:none;text-align:right;">Total</td>
                <td style="border:none;text-align:right;"><a id="total_cost"></a><input type="hidden" name="total_cost" id="t_total_cost" /></td>
            </tr>
        </table>
        
        <br />
        <div style="width:100%;text-align:center;">
            <input type="button" class="round-button" value="<< Back" onclick="location.href='./'" />&nbsp;&nbsp;
            <input type="submit" class="round-button" value="Next >>" />
        </div>
    </form>
</center>
<br />
<!-- #INCLUDE FILE="Footer.aspx" -->