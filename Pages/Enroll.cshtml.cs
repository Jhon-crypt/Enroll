using Enroll.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Enroll.Pages;

public class EnrollModel : PageModel
{
    private readonly EnrollmentDb _database;

    public EnrollModel(EnrollmentDb database)
    {
        _database = database;
    }

    public int CourseCount { get; private set; } = 1;
    public string Deleted { get; private set; } = "";
    public List<LookupItem> Campuses { get; private set; } = new();
    public string? DatabaseMessage { get; private set; }

    public IActionResult OnGet() => Show();

    public IActionResult OnPost() => Show();

    public string SelectedCampus(int index) => HttpContext.Session.GetString("camp_cod_" + index) ?? "";

    private IActionResult Show()
    {
        if (HttpContext.Session.GetString("Authenticated") != "true")
        {
            return Redirect("/Login?Message=" + Uri.EscapeDataString("Please Login To Continue"));
        }

        if (!string.IsNullOrEmpty(Request.Form["cmdNext"]))
        {
            HttpContext.Session.SetString("first_name", Request.Form["first_name"].ToString());
            HttpContext.Session.SetString("last_name", Request.Form["last_name"].ToString());
            HttpContext.Session.SetString("ssn", Request.Form["ssn"].ToString());
            HttpContext.Session.SetString("dept_cod", Request.Form["dept_cod"].ToString());
            HttpContext.Session.SetString("term", Request.Form["term"].ToString());
            HttpContext.Session.SetString("camp_cod", Request.Form["camp_cod"].ToString());
            HttpContext.Session.SetString("div_cod", Request.Form["div_cod"].ToString());

            var term = HttpContext.Session.GetString("term") ?? "";
            if (!string.IsNullOrEmpty(term))
            {
                var parts = term.Split(' ');
                if (parts.Length > 1)
                {
                    try
                    {
                        HttpContext.Session.SetString("term_semester", _database.FindSemesterCode(parts[0]));
                    }
                    catch (DatabaseUnavailableException)
                    {
                        DatabaseMessage = "The database is not connected yet, so high schools and costs cannot be loaded. Nothing was changed in the database.";
                    }

                    HttpContext.Session.SetString("term_year", parts[1]);
                }
            }
        }

        if (HttpContext.Session.GetString("Deleted_Courses") == null)
        {
            HttpContext.Session.SetString("Deleted_Courses", "");
        }

        var storedCount = HttpContext.Session.GetString("NumCourses");
        if (string.IsNullOrEmpty(storedCount) || !int.TryParse(storedCount, out var count))
        {
            count = 1;
            HttpContext.Session.SetString("NumCourses", "1");
        }

        CourseCount = count;
        Deleted = HttpContext.Session.GetString("Deleted_Courses") ?? "";

        try
        {
            Campuses = _database.GetCampuses();
        }
        catch (DatabaseUnavailableException)
        {
            DatabaseMessage = "The database is not connected yet, so high schools and costs cannot be loaded. Nothing was changed in the database.";
            Campuses = new List<LookupItem>();
        }

        return Page();
    }
}
