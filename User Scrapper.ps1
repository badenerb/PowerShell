#This script will take a users Varonis csv output file and extract the real humans from the file and output them into a new file
#Created by Baden Erb

clear
$inputFile = Read-Host -Prompt "What is the name of the Varonis csv output file (excluding the file extension)"
$FILENAME = "$inputFile.csv"
$DESKPATH = "C:\Users\" + $env:USERNAME + "\Desktop"
cd ~
Set-Location $DESKPATH

if(!(Test-Path -Path ".\$FILENAME"))
{
    Write-Host "Ensure the Varonis output file, $FILENAME, is on your desktop or exists"
    read-hos
    exit
}

Write-Host "Processing the stale users. Please be patient"

$date = Get-Date -Format "_MM_dd_yyyy_HH_mm_ss"
$newFile = "$inputFile$date.csv"
New-Item -name "$newFile" | Out-Null
Write-Host "Created new file for the data called $newFile"

Write-output ("Domain,Name,User,Email,Department,Manager") | Out-File ".\$newFile" -encoding ascii

foreach($line in Get-Content .\$FILENAME)
{
    $splitArray = @()
    $splitArray =  $line.Split(",")
    $username = $splitArray[2]
    $email = $splitArray[3]
    if(($username -match "[A-Z]{2,3}[0-9]{3,6}") -and ($email.length -lt 50) -and ($username.length -lt 8))
    {
        $input = ""
        $domain = $splitArray[0]
        $name = $splitArray[1]
        $department = $splitArray[4]
        $manager = $splitArray[5].Trim("vermeermfg.com\")
        $input = "$domain,$name,$username,$email,$department,$manager,$input"
        Write-output ($input) | Out-File ".\$newFile" -encoding ascii -Append
    }
}

write-host "`r`nProccessing complete. Press Enter to Close"
read-host