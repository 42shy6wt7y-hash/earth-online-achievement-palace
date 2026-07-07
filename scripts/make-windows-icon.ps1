param(
  [string]$InputPng = "$PSScriptRoot\..\build\app-icon.png",
  [string]$OutputIco = "$PSScriptRoot\..\build\app-icon.ico"
)

Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class NativeIcon {
  [DllImport("user32.dll", SetLastError=true)]
  public static extern bool DestroyIcon(IntPtr hIcon);
}
"@

$source = [System.Drawing.Bitmap]::FromFile((Resolve-Path $InputPng))
$size = 256
$bitmap = New-Object System.Drawing.Bitmap $size, $size
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$graphics.Clear([System.Drawing.Color]::Transparent)

$side = [Math]::Min($source.Width, $source.Height)
$srcX = [Math]::Floor(($source.Width - $side) / 2)
$srcY = [Math]::Floor(($source.Height - $side) / 2)
$srcRect = New-Object System.Drawing.Rectangle $srcX, $srcY, $side, $side
$dstRect = New-Object System.Drawing.Rectangle 0, 0, $size, $size
$graphics.DrawImage($source, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

$hicon = $bitmap.GetHicon()
$icon = [System.Drawing.Icon]::FromHandle($hicon)
$stream = [System.IO.File]::Create($OutputIco)
$icon.Save($stream)
$stream.Dispose()

[NativeIcon]::DestroyIcon($hicon) | Out-Null
$icon.Dispose()
$graphics.Dispose()
$bitmap.Dispose()
$source.Dispose()

Write-Host "Wrote $OutputIco"
