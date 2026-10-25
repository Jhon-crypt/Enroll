using Enroll.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Enroll.Pages;

public class IndexModel : PageModel
{
    private readonly EnrollmentDb _database;

    public IndexModel(EnrollmentDb database)
    {
        _database = database;
    }

    public string FirstName { get; private set; } = "";
    public string LastName { get; private set; } = "";
    public string Ssn { get; private set; } = "";
    public string DeptCod { get; private set; } = "";
    public string Term { get; private set; } = "";
    public string CampCod { get; private set; } = "";
    public string DivCod { get; private set; } = "";
    public string? DatabaseMessage { get; private set; }
    public HomeLists Lists { get; private set; } = new();

    public IActionResult OnGet()
    {
        if (HttpContext.Session.GetString("Authenticated") != "true")
        {
            return Redirect("/Login?Message=" + Uri.EscapeDataString("Please Login To Continue"));
        }

        FirstName = HttpContext.Session.GetString("first_name") ?? "";
        LastName = HttpContext.Session.GetString("last_name") ?? "";
        Ssn = HttpContext.Session.GetString("ssn") ?? "";
        DeptCod = HttpContext.Session.GetString("dept_cod") ?? "";
        Term = HttpContext.Session.GetString("term") ?? "";
        CampCod = HttpContext.Session.GetString("camp_cod") ?? "";
        DivCod = HttpContext.Session.GetString("div_cod") ?? "";

        try
        {
            Lists = _database.LoadHomeLists();
        }
        catch (DatabaseUnavailableException)
        {
            DatabaseMessage = "The database is not connected yet, so the class lists are empty. Nothing was changed in the database.";
            Lists = new HomeLists();
        }

        return Page();
    }
}
