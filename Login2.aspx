<!-- #INCLUDE FILE="Header.aspx" -->
<style>
    td {
        padding:4px;
    }
</style>
<script type="text/javascript">
    function formValidate() {
        if ($("#login_id").val() == '' || $("#password").val() == '' ) {
            alert('Please complete all fields before continuing.');
            return false;
        }
        return true;
    }
</script>
<%
    Session("Authenticated") = False
    If Request("Login") = "1" Then
        Using objCmdL As SqlClient.SqlCommand = Session("dbConn").CreateCommand()
            objCmdL.CommandText = "if exists (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101) OPEN SYMMETRIC KEY SSN_Key_01 DECRYPTION BY CERTIFICATE SSN;"
            objCmdL.ExecuteNonQuery()
            
            objCmdL.CommandText = "Select *, CONVERT(char, DecryptByKey(SSN)) as SSID from SATC_SonisWeb..name Where (Right(Rtrim(CONVERT(char, DecryptByKey(SSN))),4) = '" & Request("login_id").Replace("'", "''").Replace(";", "").Replace("%", "") & "' "
            objCmdL.CommandText &= "And last_name = '" & Request("last_name").Replace("'", "''").Replace(";", "").Replace("%", "") & "') "
            objCmdL.CommandText &= "And datepart(yyyy,birthdate) = '" & Request("birth_year").Replace("'", "''").Replace(";", "").Replace("%", "") & "' "
            Using rsLogin As SqlClient.SqlDataReader = objCmdL.ExecuteReader()
                If rsLogin.Read Then
                    'If Request("password") = Trim(rsLogin("Pin")) Then
                    Session("soc_sec") = Trim(rsLogin("soc_sec"))
                    Session("first_name") = Trim(rsLogin("first_name"))
                    Session("last_name") = Trim(rsLogin("last_name"))
		    Session("DOB") = Trim(rsLogin("birthdate"))
                    Session("ssn") = Right(Trim(rsLogin("SSID")), 4)
                    Session("camp_cod") = Trim(rsLogin("camp_cod"))
                    Session("Authenticated") = True
                    Response.Redirect("Default.aspx")
                    'Else
                    'Session("Authenticated") = False
                    'Response.Redirect("Login.aspx?Message=Login%20Incorrect")
                    'End If
                Else
                Session("Authenticated") = False
                Response.Redirect("Login.aspx?Message=Login%20Incorrect")
                End If
            End Using
        End Using

    End If
%>
<br />
<center>
    <a style="color:red;font-size:12pt;"><%=Request("Message")%></a>
    <form method="post" action="Login.aspx?Login=1" name="frmLogin" onsubmit="return formValidate()">
        <table>
            <tr>
                <td>Last Name</td>
                <td><input type="text" name="last_name" id="last_name" style="width:200px;"  /></td>
            </tr>
            <tr>
                <td>First name</td>
                <td><input type="text" name="first_name" id="login_id" style="width:200px;"  /></td>
            </tr>
            <tr>
                <td>4 Digit Year of Birth (YYYY)</td>
                <td><input type="text" name="birth_year" id="birth_year" style="width:200px;"  /></td>
            </tr>

            
            
        </table>

        <br />
        <div style="width:100%;text-align:center;">
            <input type="submit" name="cmdNext" class="round-button" value="Login" />
        </div>
    </form>
</center>
<br />
<!-- #INCLUDE FILE="Footer.aspx" -->