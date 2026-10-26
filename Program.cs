using Enroll.Services;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorPages(options =>
{
    options.Conventions.ConfigureFilter(new IgnoreAntiforgeryTokenAttribute());
});
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(120);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});
builder.Services.AddSingleton<EnrollmentDb>();

var app = builder.Build();

app.UseExceptionHandler("/error");
app.UseStaticFiles();
app.UseRouting();
app.UseSession();

app.MapGet("/error", (HttpContext context) => Results.Content(
    "<html><body><p>Something went wrong. Go back to the <a href=\"" + AppUrls.Under(context.Request.PathBase, "/Login") + "\">sign-in page</a> and try again.</p></body></html>",
    "text/html"));

app.MapRazorPages();
EnrollmentEndpoints.Map(app);

app.Run();

public partial class Program;
