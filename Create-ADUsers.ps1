#requires -module ActiveDirectory

<#
.SYNOPSIS
    Creates a specified number of users in Active Directory with randomly generated data.

.DESCRIPTION
    This script automates the creation of bulk users in Active Directory.
    It generates random names, passwords, and other attributes for each user.
    It also creates a dedicated Organizational Unit (OU) to house the new user accounts.

    Before running, please modify the variables in the "CONFIGURATION" section to match your environment.

.NOTES
    Author: Jules
    Version: 1.0
    Date: 2025-08-08

.EXAMPLE
    .\Create-ADUsers.ps1
    This command will run the script using the configuration set within the file.
#>

#--------------------------------------------------------------------------------
# CONFIGURATION - MODIFY THESE VARIABLES TO MATCH YOUR ENVIRONMENT
#--------------------------------------------------------------------------------

# The distinguished name of your domain (e.g., "DC=corp,DC=local").
# The script will try to get this automatically, but you can set it manually.
$DomainDN = (Get-ADDomain).DistinguishedName

# The name of the Organizational Unit (OU) to create the users in.
$OUName = "BulkUsers"

# The full distinguished name of the OU.
$OUPath = "OU=$OUName,$DomainDN"

# The number of users to create.
$UserCount = 500

# Set to $true to force password change at next logon for created users.
$ForcePasswordChangeOnLogon = $true

#--------------------------------------------------------------------------------
# DATA FOR RANDOM USER GENERATION
#--------------------------------------------------------------------------------

$FirstNames = @(
    "Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Heidi",
    "Ivan", "Judy", "Mallory", "Niaj", "Olivia", "Peggy", "Rupert", "Sybil",
    "Trent", "Ulysses", "Victor", "Walter", "Xavier", "Yvonne", "Zelda",
    "James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael",
    "Linda", "William", "Elizabeth", "Richard", "Barbara", "Joseph", "Susan",
    "Thomas", "Jessica", "Christopher", "Sarah", "Daniel", "Karen", "Matthew",
    "Nancy", "Anthony", "Lisa", "Donald", "Betty", "Mark", "Margaret"
)

$LastNames = @(
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller",
    "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez",

    "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
    "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark",
    "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King",
    "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green",
    "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell"
)

$Departments = @(
    "IT", "Sales", "Marketing", "Human Resources", "Finance",
    "Research and Development", "Customer Support", "Operations"
)

$JobTitles = @{
    "IT" = @("Help Desk Technician", "Network Administrator", "Systems Engineer")
    "Sales" = @("Sales Representative", "Account Executive", "Sales Manager")
    "Marketing" = @("Marketing Coordinator", "SEO Specialist", "Content Creator")
    "Human Resources" = @("HR Generalist", "Recruiter", "HR Manager")
    "Finance" = @("Accountant", "Financial Analyst", "Controller")
    "Research and Development" = @("Software Developer", "Research Scientist", "QA Engineer")
    "Customer Support" = @("Support Specialist", "Tier 2 Support", "Support Lead")
    "Operations" = @("Operations Analyst", "Logistics Coordinator", "Operations Manager")
}

$Cities = @(
    "New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia",
    "San Antonio", "San Diego", "Dallas", "San Jose"
)

#--------------------------------------------------------------------------------
# SCRIPT LOGIC - DO NOT MODIFY BELOW THIS LINE
#--------------------------------------------------------------------------------

# Function to generate a random complex password
function Get-RandomPassword {
    param(
        [int]$Length = 12
    )
    $Chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+'
    $Password = -join ((0..($Length - 1)) | ForEach-Object { $Chars[(Get-Random -Maximum $Chars.Length)] })
    return $Password
}

# Check if the target OU exists, and create it if it doesn't
if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OUPath'")) {
    Write-Host "OU '$OUName' not found. Creating it..." -ForegroundColor Yellow
    try {
        New-ADOrganizationalUnit -Name $OUName -Path $DomainDN -ProtectedFromAccidentalDeletion $false
        Write-Host "OU '$OUPath' created successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Error creating OU '$OUPath'. Please check permissions and the DomainDN variable." -ForegroundColor Red
        Write-Error $_
        exit
    }
}
else {
    Write-Host "OU '$OUPath' already exists." -ForegroundColor Cyan
}

Write-Host "Starting user creation process for $UserCount users..."

for ($i = 1; $i -le $UserCount; $i++) {
    # Generate random user data
    $FirstName = $FirstNames | Get-Random
    $LastName = $LastNames | Get-Random
    $Department = $Departments | Get-Random
    $Title = ($JobTitles[$Department]) | Get-Random
    $City = $Cities | Get-Random
    $Company = "Contoso" # Example company name
    $Description = "Standard user account created via bulk script."

    # Create unique account names
    $SamAccountName = "$($FirstName.ToLower()).$($LastName.ToLower())$(Get-Random -Minimum 10 -Maximum 99)"
    $UserPrincipalName = "$SamAccountName@$((Get-ADDomain).DnsRoot)"
    $DisplayName = "$FirstName $LastName"

    # Generate a secure random password
    $Password = Get-RandomPassword
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    # Define user attributes
    $UserParams = @{
        Name                                = $DisplayName
        GivenName                           = $FirstName
        Surname                             = $LastName
        DisplayName                         = $DisplayName
        SamAccountName                      = $SamAccountName
        UserPrincipalName                   = $UserPrincipalName
        Path                                = $OUPath
        AccountPassword                     = $SecurePassword
        Enabled                             = $true
        ChangePasswordAtLogon               = $ForcePasswordChangeOnLogon
        City                                = $City
        Company                             = $Company
        Department                          = $Department
        Title                               = $Title
        Description                         = $Description
        # Other attributes can be added here
        # OfficePhone                       = "123-456-7890"
        # StreetAddress                     = "123 Main St"
        # State                             = "CA"
        # PostalCode                        = "90210"
    }

    try {
        # Check if user already exists
        if (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'") {
            Write-Host "User '$SamAccountName' already exists. Skipping..." -ForegroundColor Yellow
            continue
        }

        # Create the new user
        New-ADUser @UserParams
        Write-Host "[$i/$UserCount] Successfully created user: $DisplayName ($UserPrincipalName) with password: $Password" -ForegroundColor Green
    }
    catch {
        Write-Host "[$i/$UserCount] Error creating user '$DisplayName'." -ForegroundColor Red
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
        # Continue to the next user
    }
}

Write-Host "User creation script finished." -ForegroundColor Blue
