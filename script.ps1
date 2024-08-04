# Define the mapping of file extensions to their corresponding icon files
$fileExtensions = @{
    ".c"      = "c.ico"
    ".h"      = "c.ico"
    ".cpp"    = "cpp.ico"
    ".cc"     = "cpp.ico"
    ".cxx"    = "cpp.ico"
    ".c++"    = "cpp.ico"
    ".hpp"    = "cpp.ico"
    ".hxx"    = "cpp.ico"
    ".h++"    = "cpp.ico"
    ".cs"     = "csharp.ico"
    ".css"    = "css.ico"
    ".go"     = "go.ico"
    ".html"   = "html.ico"
    ".htm"    = "html.ico"
    ".jade"   = "jade.ico"
    ".pug"    = "jade.ico"
    ".java"   = "java.ico"
    ".class"  = "java.ico"
    ".js"     = "javascript.ico"
    ".json"   = "json.ico"
    ".less"   = "less.ico"
    ".md"     = "markdown.ico"
    ".markdown" = "markdown.ico"
    ".php"    = "php.ico"
    ".php3"   = "php.ico"
    ".php4"   = "php.ico"
    ".php5"   = "php.ico"
    ".phtml"  = "php.ico"
    ".ps1"    = "powershell.ico"
    ".psm1"   = "powershell.ico"
    ".psd1"   = "powershell.ico"
    ".ps1xml" = "powershell.ico"
    ".py"     = "python.ico"
    ".pyc"    = "python.ico"
    ".pyo"    = "python.ico"
    ".jsx"    = "react.ico"
    ".tsx"    = "react.ico"
    ".rb"     = "ruby.ico"
    ".erb"    = "ruby.ico"
    ".sass"   = "sass.ico"
    ".scss"   = "sass.ico"
    ".sh"     = "shell.ico"
    ".bash"   = "shell.ico"
    ".zsh"    = "shell.ico"
    ".sql"    = "sql.ico"
    ".ts"     = "typescript.ico"
    ".vue"    = "vue.ico"
    ".xml"    = "xml.ico"
    ".yaml"   = "yaml.ico"
    ".yml"    = "yaml.ico"
}

# Base path to the custom icons. Example: "\VSCode-win32-x64-1.91.1\resources\app\resources\win32"
# $baseIconPath = "\VSCode-win32-x64-1.91.1\resources\app\resources\win32"
$baseIconPath = "\path\to\vs-code-icons"

# Function to get the icon file name based on the extension
function Get-IconForExtension {
    param (
        [string]$extension
    )
    if ($fileExtensions.ContainsKey($extension)) {
        return "$baseIconPath\$($fileExtensions[$extension])"
    } else {
        return "$baseIconPath\default.ico" # Default icon if extension not found
    }
}

# Iterate over each file extension
foreach ($ext in $fileExtensions.Keys) {
    $iconFile = Get-IconForExtension -extension $ext

    # Path to the registry key for the file extension in HKEY_CLASSES_ROOT
    $classesRootPath = "Registry::HKEY_CLASSES_ROOT\$ext"

    # Retrieve the default value from HKEY_CLASSES_ROOT
    $dataFromHKEY_CLASSES_ROOT = Get-ItemProperty -Path $classesRootPath -Name "(Default)" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty "(Default)"
    
    # Define paths for HKEY_LOCAL_MACHINE and HKEY_CLASSES_ROOT
    $hklmIconPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\$dataFromHKEY_CLASSES_ROOT\DefaultIcon"
    $hkcrIconPath = "Registry::HKEY_CLASSES_ROOT\$dataFromHKEY_CLASSES_ROOT\DefaultIcon"

    if (-not [string]::IsNullOrEmpty($dataFromHKEY_CLASSES_ROOT)) {
        # Set the icon in both locations

        # Ensure the DefaultIcon value exists in HKEY_LOCAL_MACHINE
        if (-not (Test-Path $hklmIconPath)) {
            New-Item -Path $hklmIconPath -Force | Out-Null
        }
        Set-ItemProperty -Path $hklmIconPath -Name "(Default)" -Value "$iconFile,0"

        # Ensure the DefaultIcon value exists in HKEY_CLASSES_ROOT
        if (-not (Test-Path $hkcrIconPath)) {
            New-Item -Path $hkcrIconPath -Force | Out-Null
        }
        Set-ItemProperty -Path $hkcrIconPath -Name "(Default)" -Value "$iconFile,0"

        Write-Output "Custom icon for $ext files has been updated."
    } else {
        # If no data exists, set the default icon in HKEY_LOCAL_MACHINE
        $localMachinePath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes\$ext\DefaultIcon"

        # Ensure the key exists in HKEY_LOCAL_MACHINE
        if (-not (Test-Path $localMachinePath)) {
            New-Item -Path $localMachinePath -Force | Out-Null
        }
        Set-ItemProperty -Path $localMachinePath -Name "(Default)" -Value "$iconFile,0"

        Write-Output "Custom icon for $ext files has been set in HKLM."
    }
}

# Refresh the icon cache
Stop-Process -Name explorer -Force
Start-Process explorer
