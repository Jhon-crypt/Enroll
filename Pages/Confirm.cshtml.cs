using System.Globalization;
using Enroll.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Enroll.Pages;

public class ConfirmRow
{
    public string Campus { get; init; } = "";
    public string CourseName { get; init; } = "";
    public string CourseNumber { get; init; } = "";
    public string Semester { get; init; } = "";
    public string Section { get; init; } = "";
    public string Faculty { get; init; } = "";
    public string Memo { get; init; } = "";
    public string Credits { get; init; } = "";
    public string Cost { get; init; } = "";
}

public class ConfirmModel : PageModel
{
    private readonly EnrollmentDb _database;

    public ConfirmModel(EnrollmentDb database)
    {
        _database = database;
    }

    public string FirstName { get; private set; } = "";
    public string LastName { get; private set; } = "";
    public string Ssn { get; private set; } = "";
    public string Total { get; private set; } = "";
    public string? DatabaseMessage { get; private set; }
    public List<ConfirmRow> Rows { get; private set; } = new();

    public IActionResult OnGet()
    {
        if (HttpContext.Session.GetString("Authenticated") != "true")
        {
            return Redirect(AppUrls.Under(Request.PathBase, "/Login?Message=" + Uri.EscapeDataString("Please Login To Continue")));
        }

        return Redirect(AppUrls.Under(Request.PathBase, "/Enroll"));
    }

    public IActionResult OnPost()
    {
        if (HttpContext.Session.GetString("Authenticated") != "true")
        {
            return Redirect(AppUrls.Under(Request.PathBase, "/Login?Message=" + Uri.EscapeDataString("Please Login To Continue")));
        }

        FirstName = HttpContext.Session.GetString("first_name") ?? "";
        LastName = HttpContext.Session.GetString("last_name") ?? "";
        Ssn = HttpContext.Session.GetString("ssn") ?? "";

        var countText = HttpContext.Session.GetString("NumCourses");
        var count = int.TryParse(countText, out var parsed) ? parsed : 0;
        var deleted = HttpContext.Session.GetString("Deleted_Courses") ?? "";
        var semester = HttpContext.Session.GetString("term_semester") ?? "";
        var year = HttpContext.Session.GetString("term_year") ?? "";

        foreach (var index in EnrollmentText.VisibleRows(count, deleted))
        {
            var postedCourse = Request.Form["hs_course_" + index].ToString().Trim();
            var courseId = int.TryParse(postedCourse, out var courseNumber)
                ? postedCourse
                : (HttpContext.Session.GetString("hs_course_" + index) ?? "").Trim();
            if (!int.TryParse(courseId, out courseNumber))
            {
                continue;
            }

            var campus = Chosen(Request.Form["campus" + index].ToString(), "camp_cod_" + index);
            var section = Chosen(Request.Form["section_" + index].ToString(), "section_" + index);
            if (string.IsNullOrEmpty(section))
            {
                section = "1";
            }

            var courseNumberText = Request.Form["course_num_" + index].ToString().Trim();
            var semesterText = Request.Form["semester_" + index].ToString().Trim();
            var faculty = Request.Form["faculty_" + index].ToString().Trim();
            var memo = Request.Form["time_" + index].ToString().Trim();
            var credits = Request.Form["credit_hours_" + index].ToString().Trim();
            var costText = Request.Form["cost_" + index].ToString().Trim();
            var title = "";
            try
            {
                if (string.IsNullOrEmpty(courseNumberText) || string.IsNullOrEmpty(semesterText) || string.IsNullOrEmpty(faculty) || string.IsNullOrEmpty(memo) || string.IsNullOrEmpty(credits) || string.IsNullOrEmpty(costText))
                {
                    var described = _database.DescribeCourse(campus, courseNumber, section, year, semester);
                    title = described.Title;
                    courseNumberText = Or(courseNumberText, described.CourseNumber);
                    semesterText = Or(semesterText, described.Semester);
                    faculty = Or(faculty, described.Faculty);
                    memo = Or(memo, described.Memo);
                    credits = Or(credits, described.Credits);
                    if (string.IsNullOrEmpty(costText) && described.Found)
                    {
                        costText = described.Cost.ToString("C", CultureInfo.GetCultureInfo("en-US"));
                    }
                }

                if (string.IsNullOrEmpty(title))
                {
                    title = _database.CourseTitle(courseNumber);
                }

                if (EnrollmentText.TryParseMoney(costText, out var cost))
                {
                    _database.SaveEnrollment(
                        FirstName,
                        LastName,
                        Ssn,
                        campus,
                        HttpContext.Session.GetString("hs_course_" + index) ?? courseId,
                        semester,
                        year,
                        section,
                        cost);
                }
                else
                {
                    DatabaseMessage = "The enrollment form is ready to print. A cost was missing, so that class was not saved.";
                }
            }
            catch (DatabaseUnavailableException)
            {
                DatabaseMessage = "The enrollment form is ready to print. It was not saved because the database is not connected yet. Nothing was changed in the database.";
            }

            Rows.Add(new ConfirmRow
            {
                Campus = campus,
                CourseName = title,
                CourseNumber = courseNumberText,
                Semester = semesterText,
                Section = section,
                Faculty = faculty,
                Memo = memo,
                Credits = credits,
                Cost = costText
            });
        }

        Total = Request.Form["total_cost"].ToString();
        if (Rows.Count > 0 && (!EnrollmentText.TryParseMoney(Total, out var postedTotal) || postedTotal == 0))
        {
            var sum = 0m;
            foreach (var row in Rows)
            {
                if (EnrollmentText.TryParseMoney(row.Cost, out var rowCost))
                {
                    sum += rowCost;
                }
            }

            if (sum > 0)
            {
                Total = sum.ToString("C", CultureInfo.GetCultureInfo("en-US"));
            }
        }

        HttpContext.Session.Clear();
        return Page();
    }

    private string Chosen(string posted, string sessionKey)
    {
        var value = posted.Trim();
        return string.IsNullOrEmpty(value) ? (HttpContext.Session.GetString(sessionKey) ?? "").Trim() : value;
    }

    private static string Or(string posted, string remembered) => string.IsNullOrEmpty(posted) ? remembered : posted;
}
