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
            return Redirect("/Login?Message=" + Uri.EscapeDataString("Please Login To Continue"));
        }

        return Redirect("/Enroll");
    }

    public IActionResult OnPost()
    {
        if (HttpContext.Session.GetString("Authenticated") != "true")
        {
            return Redirect("/Login?Message=" + Uri.EscapeDataString("Please Login To Continue"));
        }

        FirstName = HttpContext.Session.GetString("first_name") ?? "";
        LastName = HttpContext.Session.GetString("last_name") ?? "";
        Ssn = HttpContext.Session.GetString("ssn") ?? "";
        Total = Request.Form["total_cost"].ToString();

        var countText = HttpContext.Session.GetString("NumCourses");
        var count = int.TryParse(countText, out var parsed) ? parsed : 0;
        var deleted = HttpContext.Session.GetString("Deleted_Courses") ?? "";
        var semester = HttpContext.Session.GetString("term_semester") ?? "";
        var year = HttpContext.Session.GetString("term_year") ?? "";

        foreach (var index in EnrollmentText.VisibleRows(count, deleted))
        {
            var courseId = Request.Form["hs_course_" + index].ToString();
            if (!int.TryParse(courseId, out var courseNumber))
            {
                continue;
            }

            var costText = Request.Form["cost_" + index].ToString();
            var campus = Request.Form["campus" + index].ToString();
            var title = "";
            try
            {
                title = _database.CourseTitle(courseNumber);
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
                        Request.Form["section_" + index].ToString(),
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
                CourseNumber = Request.Form["course_num_" + index].ToString(),
                Semester = Request.Form["semester_" + index].ToString(),
                Section = Request.Form["section_" + index].ToString(),
                Faculty = Request.Form["faculty_" + index].ToString(),
                Memo = Request.Form["time_" + index].ToString(),
                Credits = Request.Form["credit_hours_" + index].ToString(),
                Cost = costText
            });
        }

        HttpContext.Session.Clear();
        return Page();
    }
}
