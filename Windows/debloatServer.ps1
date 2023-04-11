$removedWinCaps = @( # add comments to keep cap
    "App.StepsRecorder"
    "Browser.InternetExplorer"
#    "DirectX.Configuration.Database"
#    "Downlevel.NLS.Sorting.Versions.Server"
#    "Language.Basic"
    "Language.Handwriting"
    "Language.OCR"
    "Language.Speech"
    "Language.TextToSpeech"
    "MathRecognizer"
    "Media.WindowsMediaPlayer"
    "Microsoft.Windows.MSPaint"
#    "Microsoft.Windows.Notepad"
    "Microsoft.Windows.PowerShell.ISE"
    "Microsoft.Windows.WordPad"
    "OpenSSH.Client"
    "OpenSSH.Server"
#    "Windows.Client.ShellComponents"
    "XPS.Viewer"
)

$winCaps = Get-WindowsCapability -Online

foreach ($cap in $removedWinCaps) {
    $winCaps | Where-Object -Property Name -like "$cap*" | Remove-WindowsCapability -Online
}
