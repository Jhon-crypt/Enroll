using Enroll.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Enroll.Pages;

public class LoginModel : PageModel
{
    private readonly EnrollmentDb _database;

    public LoginModel(EnrollmentDb database)
    {
        _database = database;
    }

    public string Message { get; private set; } = "";

    public void OnGet()
    {
        HttpContext.Session.SetString("Authenticated", "false");
        Message = Request.Query["Message"].ToString();
    }

    public IActionResult OnPost()
    {
        HttpContext.Session.SetString("Authenticated", "false");
        if (Request.Query["Login"] != "1")
        {
            Message = Request.Query["Message"].ToString();
            return Page();
        }

        var last4 = Request.Form["login_id"].ToString().Trim();
        var lastName = Request.Form["last_name"].ToString().Trim();
        var birthYear = Request.Form["birth_year"].ToString().Trim();

        try
        {
            var student = _database.FindStudent(last4, lastName, birthYear);
            if (student == null)
            {
                return Redirect(AppUrls.Under(Request.PathBase, "/Login?Message=" + Uri.EscapeDataString("Login Incorrect")));
            }

            HttpContext.Session.SetString("soc_sec", student.SocSec);
            HttpContext.Session.SetString("first_name", student.FirstName);
            HttpContext.Session.SetString("last_name", student.LastName);
            HttpContext.Session.SetString("DOB", student.BirthDate);
            HttpContext.Session.SetString("ssn", student.SsnLast4);
            HttpContext.Session.SetString("camp_cod", student.CampusCode);
            HttpContext.Session.SetString("Authenticated", "true");
            return Redirect(AppUrls.Under(Request.PathBase, "/"));
        }
        catch (DatabaseUnavailableException)
        {
            Message = "The database is not connected yet, so this sign-in could not be checked. Nothing was changed in the database.";
            return Page();
        }
    }
}
