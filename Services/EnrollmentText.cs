using System.Globalization;
using System.Net;

namespace Enroll.Services;

public static class EnrollmentText
{
    public const string CourseMarker = " COURSE_RESPONSE";

    public static bool TryParseMoney(string? raw, out decimal amount)
    {
        var cleaned = (raw ?? "").Replace("$", "").Replace(",", "").Trim();
        return decimal.TryParse(cleaned, NumberStyles.Number, CultureInfo.InvariantCulture, out amount);
    }

    public static string SectionList(IEnumerable<string?> sections)
    {
        var labels = sections
            .Select(section => (section ?? "").Trim())
            .Where(section => section.Length > 0)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .OrderBy(section => int.TryParse(section, NumberStyles.Integer, CultureInfo.InvariantCulture, out var number) ? number : int.MaxValue)
            .ThenBy(section => section, StringComparer.OrdinalIgnoreCase)
            .ToList();
        return labels.Count == 0 ? "1" : string.Join(",", labels);
    }

    public static string CourseOption(string id, string name, string? sections, bool selected)
    {
        var selection = selected ? " selected=\"selected\" " : "";
        var labels = string.IsNullOrWhiteSpace(sections) ? "1" : sections.Trim();
        return "<option " + selection + "value=\"" + WebUtility.HtmlEncode(id.Trim()) + "\" data-sections=\""
            + WebUtility.HtmlEncode(labels) + "\">"
            + WebUtility.HtmlEncode(name.Trim()) + "</option>";
    }

    public static IEnumerable<int> VisibleRows(int courseCount, string? deleted)
    {
        var removed = deleted ?? "";
        for (var index = 1; index <= courseCount; index++)
        {
            if (!removed.Contains(" " + index + " ", StringComparison.Ordinal))
            {
                yield return index;
            }
        }
    }
}
