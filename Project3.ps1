#Variable Declarations
$DESKPATH = "C:\Users\" + $env:USERNAME + "\Desktop"
$BADURLS = "$DESKPATH\URLs\Bad URLs"
$PROCESSEDBADURLS = "$DESKPATH\URLs\Bad URLs\Processed Bad URLs"
$MIXEDURLS = "$DESKPATH\URLs\Mixed URLs"
$PROCESSEDMIXEDURLS = "$MIXEDURLS\Processed Mixed URLs"
$TEMP = "$DESKPATH\URLs\Temp"
$badURLArray=@()
$masterURLArray=@()
$tempURLArray=@()

#Move to home directory
cd ~

#Set path to user desktop
Set-Location $DESKPATH

#Startup Function-----------------------------------------------------------------------------------------------------
function startup
{
    clear
    #checks if Urls directory already exists and if it does removes it recursivley
    if (Test-Path .\URLs)
    {
        Remove-Item -Recurse -Force ".\URLs"
    }
    #Checks if project files.zip if it's not there closes the script
    if ( -not (Test-Path ".\Project Files.zip"))
    {
        Write-Host "Place Project_Files.zip on the desktop then run this script again"
        Write-Host "Press enter to close the script."
        Read-Host
        exit
    }
    #Unzips the file into a new directory named URLs
    Expand-Archive -Path ".\Project Files.zip" -DestinationPath .\URLs
}

#Function option_1----------------------------------------------------------------------------------------------------
function option1
{
    clear
    #checks to make sure the URL mixed file is there and if not directs the user back to the main menu
    if ( -not (Test-Path "$MIXEDURLS\Mixed URLs.txt"))
    {
        Write-Host "There are no more mixed URL files.  Press Enter to return to the main menu"
        Read-Host
        return
    }
    #Creates a temp files for good and bad URLs
    New-Item "$TEMP\tempGood" | Out-Null
    New-Item "$TEMP\tempBad" | Out-Null
    Write-Host "Processing...Please be patient"
    #opens and reads the file
    foreach ($line in Get-Content "$MIXEDURLS\Mixed URLs.txt")
    {
        #Splits the data into an array with the tab as a delimeter
        $split = $line.Split("`t")
        $url = $split[3]
        #Checks the URL to see if it is good, throws an error if it is not good
        #Then adds the URL to the corresponding temp file
        try
        {
            $req = Invoke-WebRequest -uri $url -Method Head -TimeoutSec 2 -MaximumRedirection 1
            Write-output ($line) | Out-File "$TEMP\tempGood" -encoding ascii -Append
        }
        catch
        {
            Write-output ($line) | Out-File "$TEMP\tempBad" -encoding ascii -Append
        }
    }
    #Copies and deletes the temp files to their corresponding URL text files
    foreach($line in Get-Content "$TEMP\tempBad")
    {
        Write-output ($line) | Out-File "$BADURLS\Bad URLs.txt" -encoding ascii -Append
    }
    Remove-Item "$TEMP\TempBad"
    foreach($line in Get-Content "$TEMP\tempGood")
    {
        Write-output ($line) | Out-File ".\URLs\URL Master File.txt" -encoding ascii -Append
    }
    Remove-Item "$TEMP\tempGood"
    Move-Item "$MIXEDURLS\Mixed URLs.txt" "$PROCESSEDMIXEDURLS/$(get-date -f yyyyMMddTHHmmssffff) mixed urls.txt"
}

#Function option_2----------------------------------------------------------------------------------------------------
function option2
{
    #Declares the arrays used in the function
    $badURLArray=@()
    $masterURLArray=@()
    $tempURLArray=@()
    clear
    #Checks to see if the bad urls have been processed and returns if they have been already
    if ( -not (Test-Path "$BADURLS\Bad URLs.txt"))
    {
        Write-Host "There are no more bad URL files.  Press Enter to return to the main menu."
        Read-Host
        return
    }
    Write-Host "Processing...Please be patient"
    #Creates an array for bad urls and master urls
    foreach ($line in Get-Content "$BADURLS\Bad URLs.txt")
    {
        $badURLArray+=$line
    }
    
    foreach ($line in Get-Content ".\URLs\URL Master File.txt")
    {
        if ($line.ReadCount -eq 1)
        {
            continue
        }
        $masterURLArray+=$line
    }
    #removes the bad urls from the master urls file
    $flag=0
    for ($i = 0; $i -lt $masterURLArray.Length; $i++)
    {
        for ($j = 0; $j -lt $badURLArray.Length; $j++)
        {
            if ($badURLArray[$j] -eq $masterURLArray[$i])
            {
                $flag=1
                break
            }
        }
        if($flag -ne 1)
        {
            $add = $masterURLArray[$i]
            $tempURLArray+=$add
        }
        $flag=0
    }
    #Rewrites the master url file without the bad urls
    Write-output ("Primary`tCategory`tSecondary`tCategory`tTitle`tURL") | Out-File ".\URLs\URL Master File.txt" -encoding ascii
    for($i=0;$i -lt $tempURLArray.Length; $i++)
    {
        Write-output ($tempURLArray[$i]) | Out-File ".\URLs\URL Master File.txt" -encoding ascii -Append
    }
    Move-Item "$BADURLS\Bad URLs.txt" "$PROCESSEDBADURLS/$(get-date -f yyyyMMddTHHmmssffff) bad urls.txt"
}

#Function option_3-----------------------------------------------------------------------------------------------------
function option3
{
    clear
    $flag=0
    $masterURLs=@()
    $titleMatches=@()
    #Creates an array from the master URL file
    foreach ($line in Get-Content ".\URLs\URL Master File.txt")
    {
        if ($line.ReadCount -eq 1)
        {
            continue
        }
        $masterURLs+=$line
    }
    #Gets the search critera from the user
    $search = Read-Host -Prompt "Enter all or part of a title"
    for ($i = 0; $i -lt $masterURLs.Length; $i++)
    {
        #if the array item matches the search ciritera, they get added to another array with just their title and array
        if ($masterURLs[$i] -match  $search)
        {
            $split=$masterURLs[$i].Split("`t")
            $title=$split[2]
            $url=$split[3]
            $add = "$title|$url"
            $titleMatches += $add
            $flag=1
        }
    }
    #Sorts the array and prints the array out
    clear
    if($flag -eq 1)
    {
        $titleMatches = $titleMatches | sort -Unique
        for ($i = 0; $i -lt $titleMatches.Length; $i++)
        {
            $split1 = $titleMatches[$i].Split("|")
            $t = $split1[0]
            $u = $split1[1]
            Write-Host "Title:`t$t"
            Write-Host "  URL:`t$u`r`n"
        }
    }
    else
    {
        Write-Host "No titles matched `"$search`"`r`n"
    }
    Write-Host "Press Enter to return to the main menu"
    Read-Host 
}

#A call to startup function--------------------------------------------------------------------------------------------
startup

#The menu--------------------------------------------------------------------------------------------------------------
while(0 -eq 0)
{
    clear
    write-host "----- MAIN MENU -----`r`n
Please select from the following options`r`n
1.   Process Mixed URLs
2.   Process Bad URLs
3.   Look up URLs by Title
4.   Exit`r`n"
    $sel = Read-Host -Prompt "Option #"
    if ($sel -eq 1)
    {
        option1
    }
    elseif ($sel -eq 2)
    {
        option2
    }
    elseif ($sel -eq 3)
    {
        option3
    }
    elseif ($sel -eq 4)
    {
        exit
    }
    else
    {
        clear
        Write-Host "`"$sel`" is not a valid menu option. Please press Enter to continue."
        Read-Host
    }
}