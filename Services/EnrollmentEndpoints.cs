namespace Enroll.Services;

public static class EnrollmentEndpoints
{
    public static void Map(WebApplication app)
    {
        app.MapMethods("/Course_Lookup", new[] { "GET", "POST" }, Lookup);
        app.MapPost("/Add_Course", AddCourse);
        app.MapGet("/Delete_Course", DeleteCourse);
        app.MapGet("/Logout", Logout);
        app.Map("/{page}.aspx", OldPage);
    }

    private static IResult Lookup(HttpContext context, EnrollmentDb database)
    {
        if (context.Session.GetString("Authenticated") != "true")
        {
            return Results.Redirect(AppUrls.Under(context.Request.PathBase, "/Login?Message=" + Uri.EscapeDataString("Please Login To Continue")));
        }

        var index = context.Request.Query["index"].ToString();
        if (string.Equals(context.Request.Query["mode"].ToString(), "sec", StringComparison.OrdinalIgnoreCase))
        {
            context.Session.SetString("section_" + index, context.Request.Query["sec"].ToString());
            return Results.Content(EnrollmentText.CourseMarker);
        }

        var campus = context.Request.Query["campus"].ToString();
        if (!string.IsNullOrEmpty(campus))
        {
            if (campus == "none")
            {
                return Results.Content(EnrollmentText.CourseMarker + "<option value=\"\">Select a location first</option>", "text/html");
            }

            context.Session.SetString("camp_cod_" + index, campus);
            try
            {
                var selected = context.Session.GetString("hs_course_" + index) ?? "";
                var courses = database.GetCourses(
                    context.Session.GetString("term_year") ?? "",
                    context.Session.GetString("term_semester") ?? "",
                    campus);
                var html = "<option value=\"\">Select a course</option>";
                if (index != "1")
                {
                    html += "<option value=\"delete\">Delete Line</option>";
                }

                foreach (var course in courses)
                {
                    html += EnrollmentText.CourseOption(course.Id, course.Name, course.Sections, course.Id == selected);
                }

                return Results.Content(EnrollmentText.CourseMarker + html, "text/html");
            }
            catch (DatabaseUnavailableException)
            {
                return Results.Content(EnrollmentText.CourseMarker + "<option value=\"\">The database is not connected yet</option>", "text/html");
            }
        }

        var requestedCourse = context.Request.Query["hs_course"].ToString();
        if (!string.IsNullOrEmpty(requestedCourse))
        {
            var section = context.Request.Query["Section"].ToString();
            if (string.IsNullOrEmpty(section))
            {
                section = "1";
            }

            try
            {
                var description = database.DescribeCourse(
                    context.Session.GetString("camp_cod_" + index) ?? "",
                    requestedCourse.Trim(),
                    section,
                    context.Session.GetString("term_year") ?? "",
                    context.Session.GetString("term_semester") ?? "");

                if (!string.IsNullOrEmpty(description.CourseId))
                {
                    context.Session.SetString("crs_id_" + index, description.CourseId);
                }

                context.Session.SetString("hs_course_" + index, requestedCourse);
                var savedSection = context.Session.GetString("section_" + index) ?? "";
                return Results.Content(EnrollmentText.CourseMarker + description.Payload + savedSection + "|", "text/html");
            }
            catch (DatabaseUnavailableException)
            {
                return Results.Content(EnrollmentText.CourseMarker, "text/html");
            }
        }

        context.Session.SetString("hs_course_" + index, requestedCourse);
        return Results.Content(EnrollmentText.CourseMarker);
    }

    private static IResult AddCourse(HttpContext context)
    {
        var current = context.Session.GetString("NumCourses");
        var count = string.IsNullOrEmpty(current) ? 1 : int.TryParse(current, out var parsed) ? parsed : 1;
        context.Session.SetString("NumCourses", (count + 1).ToString());
        return Results.Redirect(AppUrls.Under(context.Request.PathBase, LocalRefer(context)));
    }

    private static IResult DeleteCourse(HttpContext context)
    {
        var deleted = context.Session.GetString("Deleted_Courses") ?? "";
        context.Session.SetString("Deleted_Courses", deleted + " " + context.Request.Query["Course"] + " ");
        return Results.Redirect(AppUrls.Under(context.Request.PathBase, LocalRefer(context)));
    }

    private static IResult Logout(HttpContext context)
    {
        context.Session.Clear();
        return Results.Redirect(AppUrls.Under(context.Request.PathBase, "/"));
    }

    private static IResult OldPage(HttpContext context, string page)
    {
        var target = page.ToLowerInvariant() switch
        {
            "login" => "/Login",
            "login2" => "/Login2",
            "default" => "/",
            "enroll2" => "/Enroll",
            "confirm" => "/Confirm",
            "logout" => "/Logout",
            "add_course" => "/Add_Course",
            "delete_course" => "/Delete_Course",
            "course_lookup" => "/Course_Lookup",
            _ => "/"
        };
        return Results.Redirect(AppUrls.Under(context.Request.PathBase, target + context.Request.QueryString));
    }

    private static string LocalRefer(HttpContext context)
    {
        var refer = context.Request.Query["Refer"].ToString();
        if (refer.StartsWith('/') && !refer.StartsWith("//", StringComparison.Ordinal))
        {
            return refer;
        }

        return "/Enroll";
    }
}
