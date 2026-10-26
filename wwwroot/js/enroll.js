var lsSection;

function enrollUrl(path) {
    var base = (window.enrollBase || "").replace(/\/$/, "");
    return base + path;
}

function formatCurrency(lsNum) {
    lsNum = lsNum.toString().replace(/\$|\,/g, '');
    if (isNaN(lsNum)) {
        lsNum = "0";
    }
    var lbSign = (lsNum == (lsNum = Math.abs(lsNum)));
    lsNum = Math.floor(lsNum * 100 + 0.50000000001);
    var lsCents = lsNum % 100;
    lsNum = Math.floor(lsNum / 100).toString();
    if (lsCents < 10) {
        lsCents = "0" + lsCents;
    }
    for (var liLoop = 0; liLoop < Math.floor((lsNum.length - (1 + liLoop)) / 3); liLoop++) {
        lsNum = lsNum.substring(0, lsNum.length - (4 * liLoop + 3)) + "," +
            lsNum.substring(lsNum.length - (4 * liLoop + 3));
    }
    return ((lbSign ? "" : "-") + "$" + lsNum + "." + lsCents);
}

function NumbersOnlyA(lsData) {
    var lsOut = "";
    var lsNum = "0123456789.";
    for (var liLoop = 0; liLoop < lsData.length; liLoop++) {
        var lsChar = lsData.charAt(liLoop);
        if (lsNum.indexOf(lsChar, 0) > -1) {
            lsOut += lsChar;
        }
    }
    return lsOut;
}

function trim(stringToTrim) {
    return stringToTrim.replace(/^\s+|\s+$/g, "");
}

function setSection(index) {
    $.ajax({ type: "POST", url: enrollUrl("/Course_Lookup?") + "mode=sec&sec=" + $("#section_" + index).val() + "&hs_course=" + $("#hs_course_" + index).val() + "&index=" + index, async: false });
    lookupCourse(index);
}

function populateCourses(index) {
    $.ajax({ type: "POST", url: enrollUrl("/Course_Lookup?") + "campus=" + $("#campus" + index).val() + "&index=" + index, async: false }).done(function (data) {
        var iIndex = data.indexOf("COURSE_RESPONSE");
        if (iIndex != -1 && data.substr(iIndex + 15) != "") {
            $("#hs_course_" + index).html(data.substr(iIndex + 15));
            lookupCourse(index);
        }
    });
}

function lookupCourse(index) {
    var lsNum, lsCredits, lsFac, lsTime, lsSemester, lsOnline, lsFee;

    if ($("#hs_course_" + index).val() == "delete") {
        location.href = enrollUrl("/Delete_Course?Refer=/Enroll&Course=" + index);
        return;
    }

    lsOnline = $("#hs_course_" + index + " option:selected").text().indexOf("(Online)") != -1 ? "1" : "0";

    if ($("#hs_course_" + index).val() == "") {
        $("#course_num_" + index).html("");
        $("#semester_" + index).html("");
        $("#faculty_" + index).html("");
        $("#time_" + index).html("");
        $("#credit_hours_" + index).html("");
        $("#cost_" + index).html("");
        $("#t_course_num_" + index).val("");
        $("#t_semester_" + index).val("");
        $("#t_faculty_" + index).val("");
        $("#t_time_" + index).val("");
        $("#t_credit_hours_" + index).val("");
        $("#t_cost_" + index).val("");
        $.ajax({ type: "POST", url: enrollUrl("/Course_Lookup?") + "hs_course=&index=" + index, async: false });
        doTotals();
        return false;
    }

    $.ajax({
        type: "POST",
        url: enrollUrl("/Course_Lookup?") + "hs_course=" + $("#hs_course_" + index).val() + "&index=" + index + "&Section=" + $("#section_" + index).val() + "&Online=" + lsOnline,
        async: false
    }).done(function (data) {
        var iIndex = data.indexOf("COURSE_RESPONSE");
        if (iIndex == -1 || data.substr(iIndex + 15) == "") {
            return;
        }
        data = data.substr(iIndex + 15);
        function take() {
            var cut = data.indexOf("|");
            var value = data.substr(0, cut);
            data = data.substr(cut + 1);
            return value;
        }
        take();
        lsNum = take();
        take();
        lsCredits = take();
        take();
        lsSemester = take();
        take();
        lsTime = take();
        lsFac = take();
        lsFee = take();
        lsSection = take();

        $("#course_num_" + index).html(lsNum);
        $("#semester_" + index).html(lsSemester);
        $("#faculty_" + index).html(lsFac);
        $("#credit_hours_" + index).html(lsCredits);
        $("#cost_" + index).html(formatCurrency(lsFee));
        $("#time_" + index).html(lsTime);
        $("#t_course_num_" + index).val(lsNum);
        $("#t_semester_" + index).val(lsSemester);
        $("#t_faculty_" + index).val(lsFac);
        $("#t_credit_hours_" + index).val(lsCredits);
        $("#t_cost_" + index).val(formatCurrency(lsFee));
        $("#t_time_" + index).val(lsTime);
    });
    doTotals();

    var listed = $("#hs_course_" + index + " option:selected").attr("data-sections") || "1";
    var parts = listed.split(",");
    var keep = lsSection || $("#section_" + index).val() || $.trim(parts[0]);
    $("#section_" + index).empty();
    for (var i = 0; i < parts.length; i++) {
        var label = $.trim(parts[i]);
        if (label !== "") {
            $("#section_" + index).append($("<option>", { value: label, text: "Section " + label }));
        }
    }
    if ($("#section_" + index + " option").length === 0) {
        $("#section_" + index).append($("<option>", { value: "1", text: "Section 1" }));
    }
    if ($("#section_" + index + " option[value='" + keep + "']").length) {
        $("#section_" + index).val(keep);
    }
}

function addCourse() {
    $("#frmEnroll2").attr("action", enrollUrl("/Add_Course?Refer=/Enroll"));
    $("#frmEnroll2").submit();
}

function doTotals() {
    var ldTotal = 0;
    $(".cost").each(function () {
        if (NumbersOnlyA($(this).html()) != "") {
            ldTotal += eval(NumbersOnlyA($(this).html()));
        }
    });
    $("#total_cost").html(formatCurrency(ldTotal));
    $("#t_total_cost").val(formatCurrency(ldTotal));
}

$(document).ready(function () {
    $(".campus").each(function () {
        populateCourses($(this).attr("id").replace("campus", ""));
    });
    $(".course").each(function () {
        lookupCourse($(this).attr("id").replace("hs_course_", ""));
    });
});
