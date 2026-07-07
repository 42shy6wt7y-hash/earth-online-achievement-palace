using System;
using System.Reflection;

internal static class ListResources
{
    private static void Main(string[] args)
    {
        Assembly assembly = Assembly.LoadFile(args[0]);
        foreach (string name in assembly.GetManifestResourceNames())
        {
            Console.WriteLine(name);
        }
    }
}
