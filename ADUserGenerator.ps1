function ADUser-Generation {

    param(
        [parameter(Mandatory=$true,HelpMessage="Please enter Company name.")] 
        [string] $Company,
        [parameter(Mandatory=$false,HelpMessage="Please enter the name of the OU you want to place your users. (Default: 'Staff')")] 
        [string] $OU,
        [parameter(Mandatory=$false,HelpMessage="Please enter a 3 digit area code. (Default:727)")]
        [ValidateRange(001,999)] 
        [string] $AreaCode,
        [parameter(Mandatory=$false,HelpMessage="Number of user accounts to generate. (Default:15;Max:1500)")] 
        [ValidateRange(1,1500)] 
        [int] $UserCount,
        [parameter(Mandatory=$false,HelpMessage="Please enter a password for the generated users. (Default: 'P@ssw0rd1')")]
        [String] $Password
    )


Import-Module ActiveDirectory
$ADRootDN = (Get-ADDomain -Current LocalComputer).DistinguishedName
$DNSRoot = ((Get-ADDomain -Current LocalComputer).DNSRoot).Substring($x.IndexOf('.') + 1)

    if (!($OU)) {$OU = 'Staff'}

$WorkingOU = "OU=$OU,$ADRootDN"

## Delete previous attempt
Remove-ADOrganizationalUnit -Identity $WorkingOU -Recursive -Confirm:$False -ea 0 -wa 0 -infa 0


###################
##  Create OU's  ##
###################

$departments = @(
        [pscustomobject]@{"Name" = "Accounting"; Positions = ("Manager", "Accountant", "Bookkeepping")},
        [pscustomobject]@{"Name" = "Consulting"; Positions = ("Manager", "Administrator")},
        [pscustomobject]@{"Name" = "Customer Services"; Positions = ("Manager", "CS Rep Lvl 1", "CS Rep Lvl 2")},
        [pscustomobject]@{"Name" = "Engineering"; Positions = ("Manager", "Engineer Lvl 1", "Engineer Lvl 2", "Engineer Lvl 3")},
        [pscustomobject]@{"Name" = "Executive"; Positions = ("Executive", " Executive Assistant")},
        [pscustomobject]@{"Name" = "Finance"; Positions = ("Manager", "Financial Advisor", "Finance Intern", "Invoicing", "Collections")},
        [pscustomobject]@{"Name" = "Human Resources"; Positions = ("Manager", "HR Lvl 1", "HR Lvl 2")},
        [pscustomobject]@{"Name" = "Manufacturing"; Positions = ("Manager", "Manufacturing Lvl 1", "Manufacturing Lvl 2", "Manufacturing Lvl 3")},
        [pscustomobject]@{"Name" = "Marketing"; Positions = ("Manager", "Social Media Specialist", "Community Leader")},
        [pscustomobject]@{"Name" = "Purchasing"; Positions = ("Manager", "Purchaser", "Ordering")},
        [pscustomobject]@{"Name" = "Quality"; Positions = ("Manager", "QA Lvl 1", "QA Lvl 2", "QA Lvl 3")},
        [pscustomobject]@{"Name" = "Sales"; Positions = ("Manager", "Regional Sales Rep.", "National Sales Rep.", "New Business")},
        [pscustomobject]@{"Name" = "Training"; Positions = ("Manager", "Trainer Lvl 1", "Trainer Lvl 2")}
               )

NEW-ADOrganizationalUnit 'Staff' -ProtectedFromAccidentalDeletion $False
    $departments | ForEach-Object {$_.Name} {
        NEW-ADOrganizationalUnit -Name $_.Name -path $WorkingOU -ProtectedFromAccidentalDeletion $False
    }


###################
##   USER PREP   ##
###################

# Define how many users you want to generate
    if (!($UserCount)) {$UserCount = 15}

# User generation : Names
    $FirstNames = (Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/MartynKeigher/ADUser_Generator/main/FirstNames.csv").content | ConvertFrom-Csv -Delim ',' -Header 'FirstName'  
    $LastNames = (Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/MartynKeigher/ADUser_Generator/main/LastNames.csv").content | ConvertFrom-Csv -Delim ',' -Header 'LastName'

    $CSV_Fname = New-Object System.Collections.ArrayList
    $CSV_Lname = New-Object System.Collections.ArrayList
        
    $CSV_Fname.Add($FirstNames)
    $CSV_Lname.Add($LastNames)

    $i = 0
    Write-Host "AD Account generation started. Attempting to create $usercount accounts..." -ForegroundColor Yellow
    if ($i -lt $usercount) {
        foreach ($FirstName in $FirstNames) {
            foreach ($LastName in $LastNames) {
                $First = ($CSV_Fname | Get-Random).FirstName
                $Last = ($CSV_Lname | Get-Random).LastName
                $Fname = (Get-Culture).TextInfo.ToTitleCase($First)
                $LName = (Get-Culture).TextInfo.ToTitleCase($Last)
                $displayName = (Get-Culture).TextInfo.ToTitleCase($Fname + " " + $Lname)
                [string]$firstletter = $Fname.substring(0,1).ToLower()

# User generation : SAMAccountName
   [string]$sAMAccountName = $firstletter + $LName.ToLower()
   $userExists = $false
    Try {
        $userExists = Get-ADUser -LDAPFilter "(sAMAccountName=$sAMAccountName)"}
    Catch { }
        if ($userExists) {
            $i=$i-1
            if ($i -lt 0) {$i=0}
            Continue
        }

# User generation : Department & Title
   $departmentIndex = Get-Random -Minimum 0 -Maximum $departments.Count
   $department = $departments[$departmentIndex].Name
   $title = $departments[$departmentIndex].Positions[$(Get-Random -Minimum 0 -Maximum $departments[$departmentIndex].Positions.Count)]

# User generation : Phone Number
   if (!($areacode)) {$areacode = '727'}
   if ($areacode.Length -ne 3){
        Write-Host "Expecting 3 digits for areacode. Please re-run using 3 digits for the areacode." -ForegroundColor Yellow
            Exit
    }
        ELSE {
   $pn2 = Get-Random -Minimum 301 -Maximum 980
   $pn3 = "{0:0000}" -f  (Get-Random -Minimum 100 -Maximum 9999)
   $phonenumber = "($areacode) $pn2-$pn3"
        }

# User generation : Default Password
    if (!($Password)) {$Password = 'P@ssw0rd1'}
        $securePassword = ConvertTo-SecureString -AsPlainText $Password -Force


#######################
##   USER CREATION   ##
#######################

# Generate users
    New-ADUser -AccountPassword $securePassword -Company $company -Department $department -DisplayName $displayName -EmailAddress "$sAMAccountName@$DNSRoot" -Enabled $true -GivenName $Fname -Name $displayName -OfficePhone $phonenumber -Path $WorkingOU -SamAccountName $sAMAccountName -Surname $Lname -Title $title -UserPrincipalName "$sAMAccountName@$DNSRoot"
    Get-ADUser -Filter {Department -eq $department} -Properties Department |  Move-ADObject  -TargetPath "OU=$department,$WorkingOU"

        "Created user #" + ($i+1) + " | $displayName ($sAMAccountName) | $department | $title | $phonenumber"
            $i = $i+1
            if ($i -ge $usercount) {
                Write-Host "USER GENERATION COMPLETE!! AD Accounts created: $UserCount." -ForegroundColor Green
                if ($UserCount -eq 15) {
                    Write-Host "If you need more (or less than) than 15 users, then please re-run & use the -UserCount parameter, like this...`n`n ADUser-Generation -Company MyCompany -UserCount 500" -ForegroundColor Yellow
                    Exit
                }
                ELSE {Exit}
            }
    }
    }
}
}

