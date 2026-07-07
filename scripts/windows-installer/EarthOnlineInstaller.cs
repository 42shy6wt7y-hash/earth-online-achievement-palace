using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace EarthOnlineInstaller
{
    internal static class Program
    {
        private const string AppName = "地球online成就殿堂";
        private const string PayloadResourceSuffix = "payload.zip";

        [STAThread]
        private static void Main()
        {
            Application.EnableVisualStyles();

            try
            {
                string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                string installRoot = Path.Combine(localAppData, "Programs", "EarthOnlineAchievementPalace");
                string dataRoot = Path.Combine(localAppData, "EarthOnlineAchievementPalace");
                string archiveRoot = Path.Combine(dataRoot, "achievement-archive");

                Directory.CreateDirectory(Path.GetDirectoryName(installRoot));
                Directory.CreateDirectory(dataRoot);
                Directory.CreateDirectory(archiveRoot);

                StopRunningAppNode(installRoot);

                if (Directory.Exists(installRoot))
                {
                    DeleteDirectoryWithRetry(installRoot);
                }
                Directory.CreateDirectory(installRoot);

                string tempZip = Path.Combine(Path.GetTempPath(), "EarthOnlineAchievementPalace-payload.zip");
                Assembly assembly = Assembly.GetExecutingAssembly();
                string resourceName = assembly
                    .GetManifestResourceNames()
                    .FirstOrDefault(name => name.EndsWith(PayloadResourceSuffix, StringComparison.OrdinalIgnoreCase));

                using (Stream input = resourceName == null ? null : assembly.GetManifestResourceStream(resourceName))
                {
                    if (input == null) throw new InvalidOperationException("Missing embedded payload.");
                    using (FileStream output = File.Create(tempZip))
                    {
                        input.CopyTo(output);
                    }
                }

                ZipFile.ExtractToDirectory(tempZip, installRoot);
                File.Delete(tempZip);

                string launcher = Path.Combine(installRoot, "launch-earth-online-achievement-palace.ps1");
                string hiddenLauncher = Path.Combine(installRoot, "launch-earth-online-achievement-palace.vbs");
                string icon = Path.Combine(installRoot, "build", "app-icon.ico");
                WriteHiddenLauncher(hiddenLauncher, launcher);

                string desktop = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
                CreateShortcut(Path.Combine(desktop, AppName + ".lnk"), hiddenLauncher, installRoot, icon);

                string startMenu = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Programs), AppName);
                Directory.CreateDirectory(startMenu);
                CreateShortcut(Path.Combine(startMenu, AppName + ".lnk"), hiddenLauncher, installRoot, icon);

                MessageBox.Show(
                    "安装完成。桌面已创建快捷方式。\n\n成就档案会保存在：\n" + archiveRoot,
                    AppName,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "安装失败：\n" + ex.Message,
                    AppName,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                Environment.ExitCode = 1;
            }
        }

        private static void StopRunningAppNode(string installRoot)
        {
            string runtimeNode = Path.Combine(installRoot, "runtime", "node.exe");
            foreach (Process process in Process.GetProcessesByName("node"))
            {
                try
                {
                    string processPath = process.MainModule.FileName;
                    if (!string.Equals(processPath, runtimeNode, StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }

                    process.Kill();
                    process.WaitForExit(5000);
                }
                catch
                {
                    // Ignore processes we cannot inspect; only the Palace runtime node is a valid target.
                }
                finally
                {
                    process.Dispose();
                }
            }
        }

        private static void DeleteDirectoryWithRetry(string directory)
        {
            Exception lastError = null;
            for (int attempt = 0; attempt < 10; attempt++)
            {
                try
                {
                    Directory.Delete(directory, true);
                    return;
                }
                catch (Exception ex)
                {
                    lastError = ex;
                    System.Threading.Thread.Sleep(300);
                }
            }

            throw lastError;
        }

        private static void WriteHiddenLauncher(string hiddenLauncher, string launcher)
        {
            string escapedLauncher = launcher.Replace("\"", "\"\"");
            string script =
                "Set shell = CreateObject(\"WScript.Shell\")\r\n" +
                "shell.Run \"powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"\"" + escapedLauncher + "\"\"\", 0, False\r\n";
            File.WriteAllText(hiddenLauncher, script, Encoding.ASCII);
        }

        private static void CreateShortcut(string shortcutPath, string hiddenLauncher, string workingDirectory, string iconPath)
        {
            Type shellType = Type.GetTypeFromProgID("WScript.Shell");
            dynamic shell = Activator.CreateInstance(shellType);
            dynamic shortcut = shell.CreateShortcut(shortcutPath);
            shortcut.TargetPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), "System32", "wscript.exe");
            shortcut.Arguments = "\"" + hiddenLauncher + "\"";
            shortcut.WorkingDirectory = workingDirectory;
            shortcut.IconLocation = iconPath;
            shortcut.Description = AppName;
            shortcut.Save();

            Marshal.FinalReleaseComObject(shortcut);
            Marshal.FinalReleaseComObject(shell);
        }
    }
}
