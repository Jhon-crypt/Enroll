using Microsoft.AspNetCore.Http;

namespace Enroll.Services;

public static class AppUrls
{
    public static string Under(PathString pathBase, string pathAndQuery)
    {
        if (string.IsNullOrEmpty(pathAndQuery))
        {
            pathAndQuery = "/";
        }

        if (!pathAndQuery.StartsWith('/'))
        {
            pathAndQuery = "/" + pathAndQuery;
        }

        var prefix = pathBase.Value ?? "";
        if (prefix.EndsWith('/'))
        {
            prefix = prefix[..^1];
        }

        return prefix + pathAndQuery;
    }
}
