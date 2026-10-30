using System.Net;
using Enroll.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Enroll.Tests;

public class EnrollmentTextTests
{
    [Fact]
    public void CourseOption_lists_the_real_sections()
    {
        var option = EnrollmentText.CourseOption("15", "Welding", "1,3", false);
        Assert.Contains("data-sections=\"1,3\"", option);
        Assert.Contains(">Welding</option>", option);
    }

    [Fact]
    public void SectionList_does_not_invent_sections_that_are_missing()
    {
        Assert.Equal("1,3", EnrollmentText.SectionList(new[] { "3", "1", "3", " " }));
    }

    [Fact]
    public void Addresses_stay_inside_the_school_folder()
    {
        Assert.Equal("/Enroll/Login?Login=1", AppUrls.Under("/Enroll", "/Login?Login=1"));
        Assert.Equal("/css/site.css", AppUrls.Under("", "/css/site.css"));
    }

    [Fact]
    public void Money_parser_accepts_the_formatted_cost_from_the_form()
    {
        Assert.True(EnrollmentText.TryParseMoney("$1,250.50", out var amount));
        Assert.Equal(1250.50m, amount);
    }
}

public class SiteTests : IClassFixture<EnrollmentApplication>
{
    private readonly HttpClient _client;

    public SiteTests(EnrollmentApplication application)
    {
        _client = application.CreateClient(new WebApplicationFactoryClientOptions { AllowAutoRedirect = false });
    }

    [Fact]
    public async Task Login_page_shows_the_student_fields()
    {
        var body = await (await _client.GetAsync("/Login")).Content.ReadAsStringAsync();
        Assert.Contains("Last 4 Digits of SSN", body);
    }

    [Fact]
    public async Task Old_login_address_forwards_to_the_new_one()
    {
        var response = await _client.GetAsync("/Login.aspx");
        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
        Assert.StartsWith("/Login", response.Headers.Location?.OriginalString);
    }

    [Fact]
    public async Task Sign_in_without_the_database_keeps_the_page_up()
    {
        var response = await _client.PostAsync("/Login?Login=1", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["last_name"] = "Student",
            ["login_id"] = "1234",
            ["birth_year"] = "2008"
        }));
        var body = await response.Content.ReadAsStringAsync();
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Contains("database is not connected yet", body);
    }
}

public class SchoolFolderTests : IClassFixture<SchoolFolderApplication>
{
    private readonly HttpClient _client;

    public SchoolFolderTests(SchoolFolderApplication application)
    {
        _client = application.CreateClient(new WebApplicationFactoryClientOptions { AllowAutoRedirect = false });
    }

    [Fact]
    public async Task Login_keeps_the_design_inside_the_school_folder()
    {
        var response = await _client.GetAsync("/Enroll/Login");
        var body = await response.Content.ReadAsStringAsync();
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Contains("/Enroll/css/site.css", body);
        Assert.Contains("/Enroll/images/logo.png", body);
        Assert.Contains("action=\"/Enroll/Login?Login=1\"", body);
    }
}

public sealed class SchoolFolderApplication : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(Microsoft.AspNetCore.Hosting.IWebHostBuilder builder)
    {
        builder.ConfigureServices(services => services.AddSingleton<IStartupFilter, SchoolFolderPrefix>());
    }
}

public sealed class SchoolFolderPrefix : IStartupFilter
{
    public Action<IApplicationBuilder> Configure(Action<IApplicationBuilder> next)
    {
        return app =>
        {
            app.Use(async (context, nextMiddleware) =>
            {
                if (context.Request.Path.StartsWithSegments("/Enroll", out var rest))
                {
                    context.Request.PathBase = context.Request.PathBase.Add("/Enroll");
                    context.Request.Path = rest.HasValue ? rest : "/";
                }

                await nextMiddleware();
            });
            next(app);
        };
    }
}

public class SampleDatabase : EnrollmentDb
{
    public SampleDatabase(IConfiguration configuration, Microsoft.Extensions.Logging.ILogger<EnrollmentDb> logger)
        : base(configuration, logger)
    {
    }

    public override StudentMatch? FindStudent(string last4, string lastName, string birthYear)
        => new() { FirstName = "Ada", LastName = lastName, SsnLast4 = last4 };

    public override HomeLists LoadHomeLists() => new();

    public override List<LookupItem> GetCampuses()
        => new() { new LookupItem { Code = "CENT", Name = "Central High" } };

    public override string FindSemesterCode(string description) => "SP";

    public override string CourseTitle(string courseId) => "Welding";

    public override CourseDescription DescribeCourse(string campus, string courseId, string section, string year, string semester)
        => new()
        {
            Found = true,
            CourseId = courseId,
            Title = "Welding",
            CourseNumber = "WLD100",
            Semester = "Spring",
            Faculty = "Smith",
            Memo = "Evening",
            Credits = "3",
            Cost = 150m,
            Payload = "Welding|WLD100|HS|3|50|Spring|Central High|Evening|Smith|150|"
        };

    public override void SaveEnrollment(string firstName, string lastName, string ssn, string campus, string courseId, string semester, string year, string section, decimal cost)
    {
    }
}

public class FlowTests : IClassFixture<SampleApplication>
{
    private readonly HttpClient _client;

    public FlowTests(SampleApplication application)
    {
        _client = application.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = true,
            HandleCookies = true
        });
    }

    [Fact]
    public async Task A_student_can_reach_the_class_page_and_the_printable_form()
    {
        var home = await (await _client.PostAsync("/Login?Login=1", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["last_name"] = "Student",
            ["login_id"] = "1234",
            ["birth_year"] = "2008"
        }))).Content.ReadAsStringAsync();
        Assert.Contains("Record Found", home);

        var courses = await (await _client.PostAsync("/Enroll", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["cmdNext"] = "Continue >>",
            ["first_name"] = "Ada",
            ["last_name"] = "Student",
            ["ssn"] = "1234",
            ["term"] = "Spring 202627"
        }))).Content.ReadAsStringAsync();
        Assert.Contains("Central High", courses);

        var printed = await (await _client.PostAsync("/Confirm", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["campus1"] = "CENT",
            ["hs_course_1"] = "10",
            ["course_num_1"] = "WLD100",
            ["semester_1"] = "Spring",
            ["section_1"] = "1",
            ["faculty_1"] = "Smith",
            ["time_1"] = "Evening",
            ["credit_hours_1"] = "3",
            ["cost_1"] = "$150.00",
            ["total_cost"] = "$150.00"
        }))).Content.ReadAsStringAsync();
        Assert.Contains("Print This Page!", printed);
        Assert.Contains("Welding", printed);
        Assert.Contains("$150.00", printed);
    }

    [Fact]
    public async Task A_selected_class_is_printed_when_the_form_copy_is_blank()
    {
        await _client.PostAsync("/Login?Login=1", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["last_name"] = "Student",
            ["login_id"] = "1234",
            ["birth_year"] = "2008"
        }));
        await _client.PostAsync("/Enroll", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["cmdNext"] = "Continue >>",
            ["first_name"] = "Ada",
            ["last_name"] = "Student",
            ["ssn"] = "1234",
            ["term"] = "Spring 202627"
        }));
        await _client.PostAsync("/Course_Lookup?campus=CENT&index=1", new StringContent(""));
        await _client.PostAsync("/Course_Lookup?hs_course=10&index=1&Section=1", new StringContent(""));

        var printed = await (await _client.PostAsync("/Confirm", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["hs_course_1"] = "",
            ["total_cost"] = "$0.00"
        }))).Content.ReadAsStringAsync();

        Assert.Contains("Welding", printed);
        Assert.Contains("WLD100", printed);
        Assert.Contains("Smith", printed);
        Assert.Contains("$150.00", printed);
    }

    [Fact]
    public async Task A_text_course_id_still_fills_and_prints_the_class()
    {
        await _client.PostAsync("/Login?Login=1", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["last_name"] = "Student",
            ["login_id"] = "1234",
            ["birth_year"] = "2008"
        }));
        await _client.PostAsync("/Enroll", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["cmdNext"] = "Continue >>",
            ["first_name"] = "Ada",
            ["last_name"] = "Student",
            ["ssn"] = "1234",
            ["term"] = "Spring 202627"
        }));
        await _client.PostAsync("/Course_Lookup?campus=CENT&index=1", new StringContent(""));
        var details = await (await _client.PostAsync("/Course_Lookup?hs_course=ENGCOMP02&index=1&Section=1", new StringContent(""))).Content.ReadAsStringAsync();
        Assert.Contains("WLD100", details);

        var printed = await (await _client.PostAsync("/Confirm", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["hs_course_1"] = "ENGCOMP02",
            ["campus1"] = "CENT",
            ["section_1"] = "1",
            ["total_cost"] = "$0.00"
        }))).Content.ReadAsStringAsync();

        Assert.Contains("Welding", printed);
        Assert.Contains("WLD100", printed);
        Assert.Contains("$150.00", printed);
    }
}

public class SampleApplication : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(Microsoft.AspNetCore.Hosting.IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            var existing = services.Single(service => service.ServiceType == typeof(EnrollmentDb));
            services.Remove(existing);
            services.AddSingleton<EnrollmentDb, SampleDatabase>();
        });
    }
}

public class EnrollmentApplication : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(Microsoft.AspNetCore.Hosting.IWebHostBuilder builder)
    {
        builder.ConfigureAppConfiguration((_, config) =>
        {
            config.AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["ConnectionStrings:Satc"] = "Server=127.0.0.1,1;User ID=utility;Password=test;Initial Catalog=SATC_Sonisweb;Connect Timeout=1;Encrypt=False;Pooling=false"
            });
        });
    }
}
