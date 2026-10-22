<%@ Page ValidateRequest="false" %>
<%@ Import NameSpace="System.Data"%>
<%@ Import NameSpace="System.Security.Cryptography"%>
<%@ Import NameSpace="System.Text"%>
<%@ Import NameSpace="System.Web.Security"%>
<script type="text/javascript" src="js/jquery-1.9.1.min.js"></script>


<script type="text/javascript" src="js/md5.js"></script>
<script type="text/javascript">
    jQuery.fn.center = function () {
        this.css("position", "absolute");
        this.css("top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + $(window).scrollTop()) + "px");
        this.css("left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + $(window).scrollLeft()) + "px");
        return this;
    }
</script>
<%
Session("MailFrom") = ""
Session("MailServer") = "smtp.cox.net"
Session("SupportNumber") = ""
    
    Main()
%>
<script language="vbscript" runat="server">

'Response.Expires = -1
'Response.CacheControl = "no-cache"
Public dbConn As System.Data.SqlClient.SqlConnection
Public dbConnE As System.Data.SqlClient.SqlConnection

Sub Main()



    If Not Request.ServerVariables("SCRIPT_NAME").ToLower().Contains("login.aspx") Then
        If Not Session("Authenticated") Then
            Response.Redirect("Login.aspx?Message=Please%20Login%20To%20Continue")
        End If
    

        If IsReference(Session("dbConn")) Then
	        If Not Session("dbConn") Is Nothing Then
		        dbConn = Session("dbConn")
		        dbConnE = Session("dbConnE")
		        If dbConn.State <> System.Data.ConnectionState.Open Then
			        Session.Abandon
			        Response.Redirect ("Login.aspx")
		        End If
	        Else
		        Session.Abandon
		        Response.Redirect ("Login.aspx")
	        End If
        Else
	        Session.Abandon
	        Response.Redirect ("Login.aspx")
        End If
    End If

End Sub

    Public Function GetMD5(ByVal strChange As String) As String
        Dim pass() As Byte = Encoding.UTF8.GetBytes(strChange)
        Dim md5 As MD5 = md5.Create()
        Dim strHash As Byte() = md5.ComputeHash(pass)
        
        Dim strPassword As String = ""
        Dim i As Integer = 0
        For i = 0 To strHash.Length - 1
            strPassword = strPassword & strHash(i).ToString("X2")
        Next
        
        Return strPassword.ToLower()
    End Function

Function cSQL(ByVal sData)
	cSQL = Replace(sData, "'", "''")
End Function

Function ValidateCCNum(ByVal lsCardNum)
	Dim liLoop
	Dim lsDigit
	Dim liSum

	lsCardNum = Trim(lsCardNum)
	For liLoop = Len(lsCardNum) - 1 To 1 Step -2
	    lsDigit = cStr(cInt(Mid(lsCardNum, liLoop, 1)) * 2)
	    lsDigit = Trim(lsDigit)
	    liSum = liSum + cInt(Left(lsDigit, 1))
	    If Len(lsDigit) = 2 Then
	        liSum = liSum + cInt(Right(lsDigit, 1))
	    End If
	Next

	For liLoop = Len(lsCardNum) To 1 Step -2
	    lsDigit = cStr(cInt(Mid(lsCardNum, liLoop, 1)))
	    lsDigit = Trim(lsDigit)
	    liSum = liSum + cInt(lsDigit)
	Next

	If liSum Mod 10 = 0 Then
	    ValidateCCNum = True
	Else
	    ValidateCCNum = False
	End If
End Function

Function NumbersOnly (ByVal lsData)
	Dim liLoop
	Dim lsNum

	If Len(lsData) = 0 Then
		NumbersOnly = 0
		Exit Function
	End If

	For liLoop = 1 To Len(lsData)
		If isNumeric(Mid(lsData, liLoop, 1)) Or Mid(lsData, liLoop, 1) = "." Then
			lsNum = lsNum & Mid(lsData, liLoop, 1)
		End If
	Next

	If lsNum > "" Then 
		NumbersOnly = cDbl(Trim(lsNum))
	Else
		NumbersOnly = 0
	End If
End Function

Function NumbersOnlyA (ByVal lsData)
'The same as NumbersOnly except a decimal point, sign, etc is not allowed
'Also Preserves Leading Zeros unlike NumbersOnly

	Dim liLoop
	Dim lsNum

	If Len(lsData) = 0 Then
		NumbersOnlyA = 0
		Exit Function
	End If

	For liLoop = 1 To Len(lsData)
		If InStr(1,"0123456789",Mid(lsData, liLoop, 1)) > 0 Then
			lsNum = lsNum & Mid(lsData, liLoop, 1)
		End If
	Next

	If lsNum > "" Then 
		NumbersOnlyA = Trim(lsNum)
	Else
		NumbersOnlyA = 0
	End If	
	
End Function

Function AlphaOnly (ByVal lsData)
	Dim liLoop
	Dim lsAlpha

	If Len(lsData) = 0 Then
		AlphaOnly = ""
		Exit Function
	End If
	
	For liLoop = 1 To Len(lsData)
		If InStr(1,"abcdefghijklmnopqrstuvwxyz",Mid(LCase(lsData), liLoop, 1)) > 0 Then
			lsAlpha = lsAlpha & Mid(lsData, liLoop, 1)
		End If
	Next

	AlphaOnly = Trim(lsAlpha)
End Function

Function AlphaPosition(ByVal lsData)
	'Return Values
	'0 = No Alpha
	'1 = Alpha Only At Beginning
	'2 = Alpha Only At End
	'3 = Alpha Only At Beginning And End
	'4 = Alpha In The Middle Of Numbers
	'5 = Only Alpha
	
	
	Dim liLoop
	Dim lbN1
	Dim lbA1
	Dim lbN2
	
	If AlphaOnly(lsData) <= "" Then
		AlphaPosition = 0
		Exit Function
	End If
	
	If AlphaOnly(lsData) = lsData Then
		AlphaPosition = 5
		Exit Function
	End If	
	
	For liLoop = 1 To Len(lsData)
		If Instr(1,"0123456789",Mid(lsData,liLoop,1)) > 0 Then		
			If Not lbN1 Then
				lbN1 = True
			Else
				If lbA1 Then
					lbN2 = True
					Exit For
				End If
			End If
		ElseIf Instr(1,"abcdefghijklmnopqrstuvwxyz",Mid(LCase(lsData),liLoop,1)) > 0 Then
			If lbN1 Then
				lbA1 = True
			End If
		End If
	Next
	
	If lbN1 And lbA1 And lbN2 Then
		AlphaPosition = 4
		Exit Function
	End If

	If AlphaOnly(Left(lsData, 1)) = Left(lsData, 1) And AlphaOnly(Right(lsData, 1)) = Right(lsData, 1) Then
		AlphaPosition = 3
	ElseIf AlphaOnly(Left(lsData, 1)) = Left(lsData, 1) Then
		AlphaPosition = 1
	ElseIf AlphaOnly(Right(lsData, 1)) = Right(lsData, 1) Then
		AlphaPosition = 2		
	End If
	
End Function

Function AlphaAt(ByVal lsData, ByVal lsPos)
'lsPos Can Be "B" for Beginning or "E" for End
	Dim liLoop
	Dim lsOut

	If uCase(lsPos) = "B" Then
		For liLoop = 1 To Len(lsData)
			If NumbersOnlyA(Mid(lsData, liLoop, 1)) = Mid(lsData, liLoop, 1) Then
				Exit For
			End If
			lsOut = lsOut & Mid(lsData, liLoop, 1)
		Next
	ElseIf uCase(lsPos) = "E" Then
		For liLoop = Len(lsData) To 1 Step -1
			If NumbersOnlyA(Mid(lsData, liLoop, 1)) = Mid(lsData, liLoop, 1) Then
				Exit For
			End If
			lsOut = Mid(lsData, liLoop, 1) & lsOut
		Next
	End If

	AlphaAt = lsOut

End Function

Public Function AscB (value as Char) as Byte
    return System.Convert.ToByte(value)
End Function


Function LeftPad(ByVal lsData, ByVal liLen, ByVal lsChar)

	lsData = Trim(lsData)

	If Len(lsdata) >= liLen Then
		LeftPad = lsData
		Exit Function
	End If

	LeftPad = StrDup(liLen-Len(lsData),lsChar) & lsData

End Function


Function PrintDate(byVal lsDate)
	Dim lsDateOut

	If isDate(lsDate) Then
		lsDate = cDate(lsDate)
		lsDateOut = LeftPad(Month(lsDate),2,"0") & "-" & LeftPad(Day(lsDate),2,"0") & "-"
		lsDateOut = lsDateOut & Year(lsDate)
		PrintDate = lsDateOut
	Else
		PrintDate=""
	End If

End Function

Function PrintDateShort(byVal lsDate)
	Dim lsDateOut

	If isDate(lsDate) Then
		lsDate = cDate(lsDate)
		lsDateOut = LeftPad(Month(lsDate),2,"0") & "-" & LeftPad(Day(lsDate),2,"0") & "-"
		lsDateOut = lsDateOut & Right(Year(lsDate), 2)
		PrintDateShort = lsDateOut
	Else
		PrintDateShort=""
	End If

End Function


Function PrintPhone(byVal lsPhone)
	lsPhone = Trim(lsPhone)

	If Len(lsPhone) = 7 Then
		PrintPhone = Left(lsPhone, 3) & "-" & Right(lsPhone, 4)
	ElseIf Len(lsPhone) = 10 Then
		PrintPhone = Left(lsPhone, 3) & "-" & Mid(lsPhone, 4, 3) & "-" & Right(lsPhone, 4)
	ElseIf Len(lsPhone) = 11 Then
		PrintPhone = Left(lsPhone, 1) & "-" & Mid(lsPhone, 2, 3) & "-" & Mid(lsPhone, 5, 3) & "-" & Right(lsPhone, 4)
	Else
		PrintPhone = lsPhone
	End If
End Function

Function cFiscal(ByVal lsDate)
	If isDate(lsDate) Then
		lsDate = cDate(lsDate)
		cFiscal = Year(lsDate) & LeftPad(Month(lsDate), 2, "0")
	Else
		cFiscal = ""
	End If
End Function

Sub ShellSortArray(ByRef arrArray, ByVal liOrdinal, ByVal liCompare)
	Dim llLoop
	Dim llHold
	Dim llHVal
	Dim arrTemp
	
	If liCompare > "" Then
		liCompare = cLng(liCompare)
	Else
		liCompare = 1
	End If

    llHVal = LBound(arrArray,2)
    Do
        llHVal = 3 * llHVal + 1
    Loop Until llHVal > UBound(arrArray, 2)
    Do
        llHVal = cLng(llHVal / 3)
        For llLoop = llHVal + LBound(arrArray, 2) To UBound(arrArray, 2)
            arrTemp = CopyRow(arrArray, llLoop)
            llHold = llLoop
			Select Case liCompare
			Case 1 'String
				Do While arrArray(liOrdinal, llHold - llHVal) > arrTemp(liOrdinal)
				    CopyElement (arrArray, llHold, llHold - llHVal)
				    llHold = llHold - llHVal
				    If llHold < llHVal Then Exit Do
				Loop
            Case 2 'Number
				Do While NumbersOnly(arrArray(liOrdinal, llHold - llHVal)) > NumbersOnly(arrTemp(liOrdinal))
				    CopyElement (arrArray, llHold, llHold - llHVal)
				    llHold = llHold - llHVal
				    If llHold < llHVal Then Exit Do
				Loop
            End Select
            PasteRow (arrArray, llHold, arrTemp)
        Next
    Loop Until llHVal = LBound(arrArray)
End Sub

Function CopyRow(ByRef arrArray, ByVal llRow)
	Dim liLoop
	Dim arrTemp()
	ReDim arrTemp(Ubound(arrArray, 1))
	
	For liLoop = Lbound(arrArray, 1) To Ubound(arrArray, 1)
		arrTemp(liLoop) = arrArray(liLoop, llRow)	
	Next 
	
	CopyRow = arrTemp
End Function

Sub PasteRow(ByRef arrArray, ByVal llRow, ByRef arrSrc)
	Dim liLoop
	
	For liLoop = Lbound(arrSrc) To Ubound(arrSrc)
		arrArray(liLoop, llRow) = arrSrc(liLoop)	
	Next 
End Sub

Sub CopyElement(ByRef arrArray, ByVal llRow, llRow2)
	Dim liLoop
	
	For liLoop = LBound(arrArray, 1) To UBound(arrArray, 1)
	    arrArray(liLoop, llRow) = arrArray(liLoop, llRow2)
	Next
End Sub

Public Function RoundUp(ByVal Number)
'Returns the nearest integer >= the input number
	If cLng(Number) = cDbl(Number) Then
		RoundUp = cLng(Number)
	Else
		RoundUp = Fix(Number) + 1
	End If
End Function

Function GetNumPos(ByVal liNum)
	Select Case cLng(liNum)
	Case 1
		GetNumPos = "1st"
	Case 2
		GetNumPos = "2nd"
	Case 3
		GetNumPos = "3rd"
	Case Else
		GetNumPos = Trim(cStr(liNum)) & "th"
	End Select
End Function

Function GetMonthName(ByVal liNum)
	Select Case cInt(liNum)
		Case 1: GetMonthName = "January"
		Case 2: GetMonthName = "February"
		Case 3: GetMonthName = "March"
		Case 4: GetMonthName = "April"
		Case 5: GetMonthName = "May"
		Case 6: GetMonthName = "June"
		Case 7: GetMonthName = "July"
		Case 8: GetMonthName = "August"
		Case 9: GetMonthName = "September"
		Case 10: GetMonthName = "October"
		Case 11: GetMonthName = "November"
		Case 12: GetMonthName = "December"
	End Select
End Function

Function PCase(ByVal lsData)
Dim liLoop
Dim arrData
Dim lsOut
Dim liPos

While InStr(1,lsData,"  ") > 0
    lsData = Replace(lsData, "  ", " ")
End While

lsData = Trim(lsData)

If Trim(lsData) <= "" Then Exit Function

arrData = Split(lsData, " ")

For liLoop = 0 To uBound(arrData)
    liPos = InStr(1,arrData(liLoop),"-")
    If liPos > 0 Then
        arrData(liLoop) = Replace(PCase(Replace(arrData(liLoop),"-"," "))," ","-")
        lsOut = lsOut & arrData(liLoop) & " "
    ElseIf InStr(1,arrData(liLoop),"/") > 0 Then
        liPos = InStr(1,arrData(liLoop),"/")
        arrData(liLoop) = Replace(PCase(Replace(arrData(liLoop),"/"," "))," ","/")
        lsOut = lsOut & arrData(liLoop) & " "
    ElseIf InStr(1,arrData(liLoop),"\") > 0 Then
        liPos = InStr(1,arrData(liLoop),"\")
        arrData(liLoop) = Replace(PCase(Replace(arrData(liLoop),"\"," "))," ","\")
        lsOut = lsOut & arrData(liLoop) & " "
    Else
        If UCase(Left(arrData(liLoop),2)) = "MC" And Len(arrData(liLoop)) > 3 Then
            'lsOut = lsOut & arrData(liLoop)
            lsOut = lsOut & "Mc" & uCase(Mid(arrData(liLoop),3,1)) & lCase(Right(arrData(liLoop),Len(arrData(liLoop))-3)) & " "
        Else
            lsOut = lsOut & uCase(Left(arrData(liLoop),1)) & lCase(Right(arrData(liLoop),Len(arrData(liLoop))-1)) & " "
        End If
    End If
    
    liPos = InStr(1,lsOut,"'")
    If liPos > 0 Then
        lsOut = Replace(lsOut,"'" & Mid(lsOut,liPos+1,1),"'" & UCase(Mid(lsOut,liPos+1,1)))
    End If
Next

PCase = Trim(lsOut)
    
End Function

Function GetEOM(ByVal lsDate)
    Dim ldtDate as DateTime

    If Not IsDate(lsDate) Then 
        Exit Function
    End If

    ldtDate = CDate(lsDate)
    ldtDate = DateAdd("m", 1, CDate(Month(ldtDate) & "/1/" & Year(ldtDate)))
    GetEOM = ldtDate.AddDays(-1)
End Function

Function GetSuffix(ByVal liNum)
    If cInt(liNum) = 1 Or cInt(liNum) = 21 Or cInt(liNum) = 31 Then
        GetSuffix = "st"
    ElseIf cInt(liNum) = 2 Or cInt(liNum) = 22 Then
        GetSuffix = "nd"
    ElseIf cInt(liNum) = 3 Or cInt(liNum) = 23 Then
        GetSuffix = "rd"
    Else
        GetSuffix = "th"
    End If
End Function

</script>


<script type="text/javascript">

function openWindow(mypage,target,w,h,scroll,no,pLeft,pTop,params) {
	LeftPosition=(screen.width)?(screen.width-w)/2:0;
	TopPosition=(screen.height)?(screen.height-h)/2:0;
	if(pLeft) LeftPosition=pLeft;
	if(pTop) TopPosition=pTop;
	settings='height='+h+',width='+w+',top='+TopPosition+',left='+LeftPosition+',scrollbars='+scroll+',resizable='+no+'';
	top.win=window.open(mypage,target,settings+","+params);
}

function OpenHelp(lsFile)
{
	var lsUrl = lsFile;
	var llhWnd = window.open(lsUrl,"HelpWindow","width=350,height=375,left=0,top=0,resizable=yes,scrollbars=yes");
	if ((document.window != null) && (!llhWnd.opener))
		llhWnd.opener = document.window;
}

function OpenHelpLarge(lsFile)
{
	var lsUrl = lsFile;
	var llhWnd = window.open(lsUrl,"HelpWindow","width=640,height=480,left=0,top=0,resizable=yes,scrollbars=yes");
	if ((document.window != null) && (!llhWnd.opener))
		llhWnd.opener = document.window;
}

function isNumeric(lsData) {
	//Make sure the data is numeric and positive
	
	var lsChars = '0123456789.';
	var lsChar;
	
	lsData = lsData.toLowerCase();

	for (liLoop = 0; liLoop < lsData.length; liLoop++) {
		lsChar = lsData.charAt(liLoop);
		if (lsChars.indexOf(lsChar,0) == -1) {
			return false;
		}
	}
	
	return true;
}

function isNumericA(lsData) {
	//Make sure the data is numeric and positive with no decimals
	
	var lsChars = '0123456789';
	var lsChar;
	
	lsData = lsData.toLowerCase();

	for (liLoop = 0; liLoop < lsData.length; liLoop++) {
		lsChar = lsData.charAt(liLoop);
		if (lsChars.indexOf(lsChar,0) == -1) {
			return false;
		}
	}
	
	return true;
}

function isNumericS(lsData) {
	//Make sure the data is numeric
	
	var lsChars = '0123456789.-';
	var lsChar;
	
	lsData = lsData.toLowerCase();

	for (liLoop = 0; liLoop < lsData.length; liLoop++) {
		lsChar = lsData.charAt(liLoop);
		if (lsChars.indexOf(lsChar,0) == -1) {
			return false;
		}
	}
	
	return true;
}

function isAlpha(lsData) {
	//Make sure the data has no special characters
	
	var lsChars = '0123456789abcdefghijklmnopqrstuvwxyz';
	var lsChar;
	
	lsData = lsData.toLowerCase();

	for (liLoop = 0; liLoop < lsData.length; liLoop++) {
		lsChar = lsData.charAt(liLoop);
		if (lsChars.indexOf(lsChar,0) == -1) {
			return false;
		}
	}
	
	return true;
}

function formatDate(datestr) {
	//Warning - This function does not allow dates in the 1900's
	var sDate = new Date(datestr);
	var strDate = sDate.getFullYear().valueOf().toString();
	if (strDate.substr(0,2) == '19') {
		var fDate = sDate.getMonth() + 1 + '/' + sDate.getDate() + '/20' + strDate.substr(2,2);
	}
	else {
		var fDate = sDate.getMonth() + 1 + '/' + sDate.getDate() + '/' + sDate.getFullYear();
	}
	return fDate;
}

function isDate(dateStr) { 

    var datePat = /^(\d{1,2})(\/|-)(\d{1,2})(\/|-)(\d{4})$/; 
    var matchArray = dateStr.match(datePat); 

    
    if (matchArray == null) { 
        return false; 
    } 

    month = parseInt(matchArray[1]);
    day = parseInt(matchArray[3]);
    year = parseInt(matchArray[5]);
    
    if (month < 1 || month > 12) { 
        return false; 
    } 

    if (day < 1 || day > 31) { 
        return false; 
    } 

    if ((month==4 || month==6 || month==9 || month==11) && day==31) { 
        return false; 
    } 

    if (month == 2) { 
        var isleap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)); 
        if (day > 29 || (day==29 && !isleap)) { 
            return false; 
        } 
    } 
    return true; 
}

function isDate2(p_Expression){
	return (!isNaN(Date.parse(p_Expression)));
}

function guessDate(dateStr) {
    var datePat = /^(\d{1,2})(\/|-)(\d{1,2})(\/|-)(\d{4})$/; 
    var matchArray = dateStr.match(datePat); 

    
    if (matchArray == null) { 
        if (!isNaN(Date.parse(dateStr))) {
			return formatDate(Date.parse(dateStr));
        }
        else {
			return dateStr;
        }
    } 
    else {
		return formatDate(Date.parse(dateStr));
    }
}

function dateDiff(p_Interval, p_Date1, p_Date2){
	p_Date1 = p_Date1.replace("-", "/").replace("-", "/");
	p_Date2 = p_Date2.replace("-", "/").replace("-", "/");
	if(!isDate2(p_Date1)){return "invalid date: '" + p_Date1 + "'";}
	if(!isDate2(p_Date2)){return "invalid date: '" + p_Date2 + "'";}
	var dt1 = new Date(p_Date1);
	var dt2 = new Date(p_Date2);

	// get ms between dates (UTC) and make into "difference" date
	var iDiffMS = dt2.valueOf() - dt1.valueOf();
	var dtDiff = new Date(iDiffMS);

	// calc various diffs
	var nYears  = dt2.getUTCFullYear() - dt1.getUTCFullYear();
	var nMonths = dt2.getUTCMonth() - dt1.getUTCMonth() + (nYears!=0 ? nYears*12 : 0);
	var nQuarters = parseInt(nMonths/3);	//<<-- different than VBScript, which watches rollover not completion
	
	var nMilliseconds = iDiffMS;
	var nSeconds = parseInt(iDiffMS/1000);
	var nMinutes = parseInt(nSeconds/60);
	var nHours = parseInt(nMinutes/60);
	var nDays  = parseInt(nHours/24);
	var nWeeks = parseInt(nDays/7);


	// return requested difference
	var iDiff = 0;		
	switch(p_Interval.toLowerCase()){
		case "yyyy": return nYears;
		case "q": return nQuarters;
		case "m": return nMonths;
		case "y": 		// day of year
		case "d": return nDays;
		case "w": return nDays;
		case "ww":return nWeeks;		// week of year	// <-- inaccurate, WW should count calendar weeks (# of sundays) between
		case "h": return nHours;
		case "n": return nMinutes;
		case "s": return nSeconds;
		case "ms":return nMilliseconds;	// millisecond	// <-- extension for JS, NOT available in VBScript
		default: return "invalid interval: '" + p_Interval + "'";
	}
}


function dateAdd(p_Interval, p_Number, p_Date){
	p_Date = p_Date.replace("-", "/").replace("-", "/");
	if(!isDate2(p_Date)){return "invalid date: '" + p_Date + "'";}
	if(isNaN(p_Number)){return "invalid number: '" + p_Number + "'";}	

	p_Number = new Number(p_Number);
	var dt = new Date(p_Date);
	switch(p_Interval.toLowerCase()){
		case "yyyy": {// year
			dt.setFullYear(dt.getFullYear() + p_Number);
			break;
		}
		case "q": {		// quarter
			dt.setMonth(dt.getMonth() + (p_Number*3));
			break;
		}
		case "m": {		// month
			dt.setMonth(dt.getMonth() + p_Number);
			break;
		}
		case "y":		// day of year
		case "d":		// day
		case "w": {		// weekday
			dt.setDate(dt.getDate() + p_Number);
			break;
		}
		case "ww": {	// week of year
			dt.setDate(dt.getDate() + (p_Number*7));
			break;
		}
		case "h": {		// hour
			dt.setHours(dt.getHours() + p_Number);
			break;
		}
		case "n": {		// minute
			dt.setMinutes(dt.getMinutes() + p_Number);
			break;
		}
		case "s": {		// second
			dt.setSeconds(dt.getSeconds() + p_Number);
			break;
		}
		case "ms": {		// second
			dt.setMilliseconds(dt.getMilliseconds() + p_Number);
			break;
		}
		default: {
			return "invalid interval: '" + p_Interval + "'";
		}
	}
	return dt;
}

function DateAdd(p_Interval, p_Number, p_Date) {
	//Wrapper
	
	return dateAdd(p_Interval, p_Number, p_Date);
}

function dateadd(p_Interval, p_Number, p_Date) {
	//Wrapper
	
	return dateAdd(p_Interval, p_Number, p_Date);
}

function ValidEmail(lsAddress) {
	//Validate that the address has a '@' and a '.' in it.
	var liPos = lsAddress.search("[@]");
	if (liPos > -1) {
		var liPos1 = lsAddress.search("[.]");
		if (liPos1 == -1) {
			return false;
		}
		else {
			if (lsAddress.indexOf(' ',0) != -1) {
				return false;
			}
			else {
				return true;
			}
		}
	}
	else {
		return false;
	}
}

function formatCurrency(lsNum) {
	lsNum = lsNum.toString().replace(/\$|\,/g,'');
	if (isNaN(lsNum)) {
		lsNum = "0";
	}
	lbSign = (lsNum == (lsNum = Math.abs(lsNum)));
	lsNum = Math.floor(lsNum*100+0.50000000001);
	lsCents = lsNum%100;
	lsNum = Math.floor(lsNum/100).toString();
	if (lsCents < '10') {
		lsCents = '0' + lsCents;
	}
	//Put commas every 3 spaces
	for (var liLoop = 0; liLoop < Math.floor((lsNum.length-(1+liLoop))/3); liLoop++) {
		lsNum = lsNum.substring(0,lsNum.length-(4*liLoop+3))+','+
		lsNum.substring(lsNum.length-(4*liLoop+3));
	}
	return (((lbSign)?'':'-') + '$' + lsNum + '.' + lsCents);
}

function formatCurrencyA(lsNum) {
	//No $ in front of the number
	lsNum = lsNum.toString().replace(/\$|\,/g,'');
	if (isNaN(lsNum)) {
		lsNum = "0";
	}
	lbSign = (lsNum == (lsNum = Math.abs(lsNum)));
	lsNum = Math.floor(lsNum*100+0.50000000001);
	lsCents = lsNum%100;
	lsNum = Math.floor(lsNum/100).toString();
	if (lsCents < '10') {
		lsCents = '0' + lsCents;
	}
	//Put commas every 3 spaces
	for (var liLoop = 0; liLoop < Math.floor((lsNum.length-(1+liLoop))/3); liLoop++) {
		lsNum = lsNum.substring(0,lsNum.length-(4*liLoop+3))+','+
		lsNum.substring(lsNum.length-(4*liLoop+3));
	}
	return (((lbSign)?'':'-') + lsNum + '.' + lsCents);
}

function formatCurrencyN(lsNum) {
	//No $ in front of the number or commas in the number
	lsNum = lsNum.toString().replace(/\$|\,/g,'');
	if (isNaN(lsNum)) {
		lsNum = "0";
	}
	lbSign = (lsNum == (lsNum = Math.abs(lsNum)));
	lsNum = Math.floor(lsNum*100+0.50000000001);
	lsCents = lsNum%100;
	lsNum = Math.floor(lsNum/100).toString();
	if (lsCents < '10') {
		lsCents = '0' + lsCents;
	}
	return (((lbSign)?'':'-') + lsNum + '.' + lsCents);
}

function StripLeadingZeros(lsData) {
	var lbNZFound = false;
	var lsOut = '';
	for (liLoop = 0; liLoop < lsData.length; liLoop++) {
		if (lsData.charAt(liLoop) > '0') {
			lbNZFound = true;
		}
		
		if (lbNZFound) {
			lsOut += lsData.charAt(liLoop);
		}
	}
	
	return lsOut;
}

function NumbersOnly(lsData) {
	var lsOut = '';
	var lsChar;
	var lsNum = '0123456789';
	
	for (liLoop = 0; liLoop < lsData.length; liLoop++) {
		lsChar = lsData.charAt(liLoop);
		if (lsNum.indexOf(lsChar,0) > -1) {
			lsOut += lsChar;
		}
	}
	
	return lsOut;
}

function Fix(lsData) {
	//Drop decimals and return a whole number (Like the VB Function)
	var lsOut = '';
	var lsChar;
	var lsNum = '.';
	
	for (liLoop = 0; liLoop < lsData.length; liLoop++) {
		lsChar = lsData.charAt(liLoop);
		if (lsNum.indexOf(lsChar,0) > -1) {
			return lsOut;
		}
		else {
			lsOut += lsChar;
		}
	}
	
	return lsOut;
}

function NumbersOnlyA(lsData) {
	//allows decimals
	var lsOut = '';
	var lsChar;
	var lsNum = '0123456789.';
	
	for (liLoop = 0; liLoop < lsData.length; liLoop++) {
		lsChar = lsData.charAt(liLoop);
		if (lsNum.indexOf(lsChar,0) > -1) {
			lsOut += lsChar;
		}
	}
	
	return lsOut;
}

function AlphaOnly(lsData) {
	var lsOut = '';
	var lsChar;
	var lsNum = '0123456789';
	
	for (liLoop = 0; liLoop < lsData.length; liLoop++) {
		lsChar = lsData.charAt(liLoop);
		if (lsNum.indexOf(lsChar,0) == -1) {
			lsOut += lsChar;
		}
	}
	
	return lsOut;
}

function Left(lsData, liLength) {
	if (lsData.length <= liLength) {
		return lsData;
	}
	else {
		return lsData.substring(0,liLength)
	}
}

function AlphaPosition(lsData) {
	//Return Values
	//0 = No Alpha
	//1 = Alpha Only At Beginning
	//2 = Alpha Only At End
	//3 = Alpha Only At Beginning And End
	//4 = Alpha In The Middle Of Numbers
	//5 = Only Alpha
	
	
	var liLoop;
	var lbN1 = false;
	var lbA1 = false;
	var lbN2 = false;
	var lsNum = '0123456789';
	var lsLet = 'abcdefghijklmnopqrstuvwxyz';
	var lsChar;
	
	if (AlphaOnly(lsData) <= '') {
		return 0;
	}
	
	if (AlphaOnly(lsData) == lsData) {
		return 5;
	}
	
	for (liLoop = 0; liLoop < lsData.length; liLoop++) {
		lsChar = lsData.charAt(liLoop);
		if (lsNum.indexOf(lsChar) != -1) {
			if (!lbN1) {
				lbN1 = true;
			}
			else {
				if (lbA1) {
					lbN2 = true;
					break;
				}
			}
		}
		else if (lsLet.indexOf(lsChar.toLowerCase()) != -1) {
			if (lbN1) {
				lbA1 = true;
			}
		}
	}
	
	if (lbN1 && lbA1 && lbN2) {
		return 4;
	}

	if (AlphaOnly(lsData.charAt(0)) == lsData.charAt(0) && AlphaOnly(lsData.charAt(lsData.length-1)) == lsData.charAt(lsData.length-1)) {
		return 3;
	}
	else if (AlphaOnly(lsData.charAt(0)) == lsData.charAt(0)) {
		return 1;
	}
	else if (AlphaOnly(lsData.charAt(lsData.length-1)) == lsData.charAt(lsData.length-1)) {
		return 2;
	}
	
}

var objAjax;
var gsAjaxResp
function doPostBack(lsURL) {
   if (window.XMLHttpRequest) {
       objAjax = new XMLHttpRequest();
   } else if (window.ActiveXObject) {
       objAjax = new ActiveXObject("MSXML2.XMLHTTP.3.0");
   }
  objAjax.open("GET", lsURL, true);
  objAjax.onreadystatechange = AjaxCallBack;
  objAjax.send(null);
}

function AjaxCallBack() {
    if (objAjax.readyState == 4) {
         if (objAjax.status == 200) {
          gsAjaxResp = objAjax.responseText;
        }
    }
}

function setCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

function getCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function clearCookie(name) {
	setCookie(name,"",-1);
}

function trim(stringToTrim) {
    return stringToTrim.replace(/^\s+|\s+$/g, "");
}

function ValidateCCNum(lsCardNum) {
    var liLoop = 0;
    var lsDigit = '';
    var liSum = 0;
    var lsTypes = '3456';

    lsCardNum = trim(lsCardNum);

    //see if a value was passed
    if (lsCardNum.length == 0) {
        return false;
    }

    //see if card begins wih a valid number (3,4,5,6)
    if (lsTypes.indexOf(lsCardNum.charAt(0)) == -1) {
        return false;
    }

    //validate 15 character length for amex
    if (lsCardNum.charAt(0) == '3' && lsCardNum.length != 15) {
        return false;
    }
    else if (lsCardNum.length != 16) { //validate 16 characters for all others
        return false;
    }

    //perform the checksum validation
    for (liLoop = lsCardNum.length - 1; liLoop >= 1; liLoop-=2) {
        lsDigit = (eval(lsCardNum.charAt(liLoop-1)) * 2).toString();
        liSum += eval(lsDigit.charAt(0));
        if (lsDigit.length == 2) {
            liSum += eval(lsDigit.charAt(1));
        }
    }

    for (liLoop = lsCardNum.length; liLoop > 1; liLoop -= 2) {
        lsDigit = eval(lsCardNum.charAt(liLoop - 1)).toString();
        liSum += eval(lsDigit);
    }

    if (liSum % 10 == 0) {
        return true;
    }
    else {
        return false;
    }

}

function findLeft(obj) {
    var curleft = curtop = 0;
    if (obj.offsetParent) {
        do {
            curleft += obj.offsetLeft;
        } while (obj = obj.offsetParent);
    }
    return curleft;
}

function findTop(obj) {
    var curleft = curtop = 0;
    if (obj.offsetParent) {
        do {
            curtop += obj.offsetTop;
        } while (obj = obj.offsetParent);
    }
    return curtop;
}
</script>