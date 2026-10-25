using System.Globalization;
using Microsoft.Data.SqlClient;

namespace Enroll.Services;

public sealed class DatabaseUnavailableException : Exception
{
    public DatabaseUnavailableException()
        : base("The database is not connected yet.")
    {
    }
}

public sealed class LookupItem
{
    public string Code { get; init; } = "";
    public string Name { get; init; } = "";
}

public sealed class HomeLists
{
    public List<LookupItem> Departments { get; } = new();
    public List<string> Terms { get; } = new();
    public List<LookupItem> Campuses { get; } = new();
}

public sealed class StudentMatch
{
    public string SocSec { get; init; } = "";
    public string FirstName { get; init; } = "";
    public string LastName { get; init; } = "";
    public string BirthDate { get; init; } = "";
    public string SsnLast4 { get; init; } = "";
    public string CampusCode { get; init; } = "";
}

public sealed class CourseChoice
{
    public string Id { get; init; } = "";
    public string Name { get; init; } = "";
    public string Sections { get; init; } = "";
}

public sealed class CourseDescription
{
    public bool Found { get; init; }
    public string Payload { get; init; } = "";
    public string CourseId { get; init; } = "";
}

public class EnrollmentDb
{
    private readonly string _connectionString;
    private readonly ILogger<EnrollmentDb> _logger;

    public EnrollmentDb(IConfiguration configuration, ILogger<EnrollmentDb> logger)
    {
        _connectionString = configuration.GetConnectionString("Satc")
            ?? throw new InvalidOperationException("Connection string Satc is missing.");
        _logger = logger;
    }

    public virtual StudentMatch? FindStudent(string last4, string lastName, string birthYear)
    {
        return Using(connection =>
        {
            using var openKey = connection.CreateCommand();
            openKey.CommandText = "if exists (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101) OPEN SYMMETRIC KEY SSN_Key_01 DECRYPTION BY CERTIFICATE SSN;";
            openKey.ExecuteNonQuery();

            using var command = connection.CreateCommand();
            command.CommandText = """
                Select *, CONVERT(char, DecryptByKey(SSN)) as SSID
                from SATC_SonisWeb..name
                Where Right(Rtrim(CONVERT(char, DecryptByKey(SSN))), 4) = @loginId
                And last_name = @lastName
                And datepart(yyyy, birthdate) = @birthYear
                """;
            command.Parameters.AddWithValue("@loginId", last4);
            command.Parameters.AddWithValue("@lastName", lastName);
            command.Parameters.AddWithValue("@birthYear", birthYear);

            using var reader = command.ExecuteReader();
            if (!reader.Read())
            {
                return null;
            }

            var ssid = Text(reader, "SSID");
            var lastFour = ssid.Length <= 4 ? ssid : ssid[^4..];
            return new StudentMatch
            {
                SocSec = Text(reader, "soc_sec"),
                FirstName = Text(reader, "first_name"),
                LastName = Text(reader, "last_name"),
                BirthDate = Text(reader, "birthdate"),
                SsnLast4 = lastFour,
                CampusCode = Text(reader, "camp_cod")
            };
        });
    }

    public virtual HomeLists LoadHomeLists()
    {
        return Using(connection =>
        {
            var lists = new HomeLists();
            using (var command = connection.CreateCommand())
            {
                command.CommandText = "Select dept_cod, dept_txt from dept Where exclude_outside = 0";
                using var reader = command.ExecuteReader();
                while (reader.Read())
                {
                    lists.Departments.Add(new LookupItem { Code = Text(reader, "dept_cod"), Name = Text(reader, "dept_txt") });
                }
            }

            using (var command = connection.CreateCommand())
            {
                command.CommandText = """
                    SELECT DISTINCT RTRIM(semester.sm_desc) + ' ' + RTRIM(crssect.sch_yr) AS Semester
                    FROM crssect
                    INNER JOIN semester ON semester.semester = crssect.semester
                    WHERE crssect.cancel = 0 AND crssect.end_dt > GETDATE()
                    """;
                using var reader = command.ExecuteReader();
                while (reader.Read())
                {
                    lists.Terms.Add(Text(reader, "Semester"));
                }
            }

            lists.Campuses.AddRange(ReadCampuses(connection));
            return lists;
        });
    }

    public virtual List<LookupItem> GetCampuses()
    {
        return Using(connection => ReadCampuses(connection));
    }

    public virtual string FindSemesterCode(string description)
    {
        return Using(connection =>
        {
            using var command = connection.CreateCommand();
            command.CommandText = "Select semester from semester where sm_desc = @description";
            command.Parameters.AddWithValue("@description", description);
            return command.ExecuteScalar()?.ToString()?.Trim() ?? "";
        });
    }

    public virtual string FindCampusName(string code)
    {
        return Using(connection =>
        {
            using var command = connection.CreateCommand();
            command.CommandText = "Select camp_txt from campus where camp_cod = @code";
            command.Parameters.AddWithValue("@code", code);
            return command.ExecuteScalar()?.ToString()?.Trim() ?? "";
        });
    }

    public virtual List<CourseChoice> GetCourses(string year, string semester, string campus)
    {
        return Using(connection =>
        {
            using var command = connection.CreateCommand();
            command.CommandText = """
                Select course.crs_id as UID, crs_txt as camp_course_name, crssect.section
                From course
                Inner Join crssect on crssect.crs_id = course.crs_id
                    And crssect.camp_cod = @campus
                    And crssect.cancel = 0
                    And crssect.end_dt > GETDATE()
                Order By
                    Case When RTRIM(crssect.sch_yr) = @year And RTRIM(crssect.semester) = @semester Then 0 Else 1 End,
                    crs_txt, crssect.section
                """;
            command.Parameters.AddWithValue("@year", year);
            command.Parameters.AddWithValue("@semester", semester);
            command.Parameters.AddWithValue("@campus", campus);
            var grouped = new List<(string Id, string Name, List<string> Sections)>();
            var indexById = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            using var reader = command.ExecuteReader();
            while (reader.Read())
            {
                var id = Text(reader, "UID");
                if (!indexById.TryGetValue(id, out var index))
                {
                    index = grouped.Count;
                    indexById[id] = index;
                    grouped.Add((id, Text(reader, "camp_course_name"), new List<string>()));
                }

                grouped[index].Sections.Add(Text(reader, "section"));
            }

            return grouped.Select(course => new CourseChoice
            {
                Id = course.Id,
                Name = course.Name,
                Sections = EnrollmentText.SectionList(course.Sections)
            }).ToList();
        });
    }

    public virtual CourseDescription DescribeCourse(string campus, int courseId, string section, string year, string semester)
    {
        return Using(connection =>
        {
            using var command = connection.CreateCommand();
            command.CommandText = """
                Select Top (1) course.*, semester.sm_desc, crssect.lead_fac, campus.camp_txt, timedesc, crssect.sid, crssect.memo
                From course
                Left Join campus_course On campus_course.course = course.course
                Inner Join crssect on crssect.crs_id = course.crs_id And crssect.camp_cod = @campus
                Inner Join semester on semester.semester = crssect.semester
                Inner Join campus on campus.camp_cod = crssect.camp_cod
                Where course.crs_id = @courseId And crssect.section = @section
                    And crssect.cancel = 0 And crssect.end_dt > GETDATE()
                Order By
                    Case When RTRIM(crssect.sch_yr) = @year And RTRIM(crssect.semester) = @semester Then 0 Else 1 End,
                    crssect.end_dt
                """;
            command.Parameters.AddWithValue("@campus", campus);
            command.Parameters.AddWithValue("@semester", semester);
            command.Parameters.AddWithValue("@courseId", courseId);
            command.Parameters.AddWithValue("@section", section);
            command.Parameters.AddWithValue("@year", year);

            string payload;
            var found = false;
            var courseKey = "";
            var facultyId = "";
            decimal credits = 0;
            decimal fee = 0;
            var sid = "";

            using (var reader = command.ExecuteReader())
            {
                if (reader.Read())
                {
                    found = true;
                    courseKey = Text(reader, "crs_id");
                    facultyId = Text(reader, "lead_fac");
                    credits = Number(reader, "credits");
                    fee = credits * Number(reader, "npercred");
                    sid = Text(reader, "sid");
                    payload = string.Join("|",
                        Text(reader, "crs_txt"),
                        Text(reader, "course"),
                        Text(reader, "dept_cod"),
                        Text(reader, "credits"),
                        Text(reader, "npercred"),
                        Text(reader, "sm_desc"),
                        Text(reader, "camp_txt").Replace("'", ""),
                        Text(reader, "memo")) + "|";
                }
                else
                {
                    payload = "";
                }
            }

            var faculty = "";
            using (var facultyCommand = connection.CreateCommand())
            {
                facultyCommand.CommandText = "Select first_name, last_name from name Where soc_sec = @faculty";
                facultyCommand.Parameters.AddWithValue("@faculty", facultyId);
                using var reader = facultyCommand.ExecuteReader();
                if (reader.Read())
                {
                    faculty = Text(reader, "last_name") + "|";
                }
            }

            using (var amountCommand = connection.CreateCommand())
            {
                amountCommand.CommandText = "Select amount from CRSAFF Where crs_id = @courseId And affiliation_cod = 'HS'";
                amountCommand.Parameters.AddWithValue("@courseId", courseKey);
                var amount = amountCommand.ExecuteScalar();
                fee = amount is null or DBNull ? 0 : credits * Convert.ToDecimal(amount, CultureInfo.InvariantCulture);
            }

            using (var feesCommand = connection.CreateCommand())
            {
                feesCommand.CommandText = "Select sum(fee_amnt) from fees Where crs_id = @courseId and affiliation_cod <> 'MI'";
                feesCommand.Parameters.AddWithValue("@courseId", courseKey);
                fee += ScalarDecimal(feesCommand.ExecuteScalar());
            }

            using (var sectionFees = connection.CreateCommand())
            {
                sectionFees.CommandText = "Select Sum(fee_amnt) from feessec where sid = @sid";
                sectionFees.Parameters.AddWithValue("@sid", sid);
                var sectionFee = sectionFees.ExecuteScalar();
                if (sectionFee is not null and not DBNull)
                {
                    fee += Convert.ToDecimal(sectionFee, CultureInfo.InvariantCulture);
                }
            }

            payload += faculty;
            payload += fee.ToString(CultureInfo.InvariantCulture) + "|";
            return new CourseDescription { Found = found, Payload = payload, CourseId = courseKey };
        });
    }

    public virtual string CourseTitle(int courseId)
    {
        return Using(connection =>
        {
            using var command = connection.CreateCommand();
            command.CommandText = "Select crs_txt from course Where crs_id = @courseId";
            command.Parameters.AddWithValue("@courseId", courseId);
            return command.ExecuteScalar()?.ToString()?.Trim() ?? "";
        });
    }

    public virtual void SaveEnrollment(string firstName, string lastName, string ssn, string campus, string courseId, string semester, string year, string section, decimal cost)
    {
        Using(connection =>
        {
            using var command = connection.CreateCommand();
            command.CommandText = """
                Insert Into web_enroll
                    (first_name, last_name, ssn, camp_cod, hs_course, crs_id, term_semester, term_year, section, cost)
                values
                    (@firstName, @lastName, @ssn, @campus, 0, @courseId, @semester, @year, @section, @cost)
                """;
            command.Parameters.AddWithValue("@firstName", firstName);
            command.Parameters.AddWithValue("@lastName", lastName);
            command.Parameters.AddWithValue("@ssn", ssn);
            command.Parameters.AddWithValue("@campus", campus);
            command.Parameters.AddWithValue("@courseId", courseId);
            command.Parameters.AddWithValue("@semester", semester);
            command.Parameters.AddWithValue("@year", year);
            command.Parameters.AddWithValue("@section", section);
            command.Parameters.Add("@cost", System.Data.SqlDbType.Money).Value = cost;
            command.ExecuteNonQuery();
            return 0;
        });
    }

    private static List<LookupItem> ReadCampuses(SqlConnection connection)
    {
        using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT DISTINCT crssect.camp_cod, campus.camp_txt
            FROM crssect
            INNER JOIN campus on campus.camp_cod = crssect.camp_cod
            WHERE crssect.cancel = 0 AND crssect.end_dt > GETDATE()
            """;
        var campuses = new List<LookupItem>();
        using var reader = command.ExecuteReader();
        while (reader.Read())
        {
            var code = Text(reader, "camp_cod");
            campuses.Add(new LookupItem
            {
                Code = code,
                Name = code == "ONL" ? "Online" : Text(reader, "camp_txt")
            });
        }

        return campuses;
    }

    private T Using<T>(Func<SqlConnection, T> work)
    {
        try
        {
            using var connection = new SqlConnection(_connectionString);
            connection.Open();
            return work(connection);
        }
        catch (Exception ex) when (ex is SqlException or InvalidOperationException or TimeoutException)
        {
            _logger.LogWarning(ex, "The enrollment database could not be reached.");
            throw new DatabaseUnavailableException();
        }
    }

    private static string Text(SqlDataReader reader, string name)
    {
        var ordinal = reader.GetOrdinal(name);
        return reader.IsDBNull(ordinal) ? "" : reader.GetValue(ordinal)?.ToString()?.Trim() ?? "";
    }

    private static decimal Number(SqlDataReader reader, string name)
    {
        var ordinal = reader.GetOrdinal(name);
        return reader.IsDBNull(ordinal) ? 0 : Convert.ToDecimal(reader.GetValue(ordinal), CultureInfo.InvariantCulture);
    }

    private static decimal ScalarDecimal(object? value)
    {
        if (value is null or DBNull)
        {
            return 0;
        }

        return Convert.ToDecimal(value, CultureInfo.InvariantCulture);
    }
}
