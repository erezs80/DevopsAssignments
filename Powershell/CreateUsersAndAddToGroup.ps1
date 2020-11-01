param(
    [string]
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $password
)

###Connect to Azure AD
$tenantid = "xxxxxxxxxxxxxxxxxxxxx" # Tenant ID we want to manage
Connect-AzAccount -Tenant $tenantid # Connect to azure to the tenant we want to manage

### Parameters definitaion
$securepassword = ConvertTo-SecureString $password -AsPlainText -force
$ADGroupName = "Varonis Assignment Group"
$retries = 3

### Functions definitaion
Function Log {
    param(
        [Parameter(Mandatory=$true)][String]$msg
    )
    
    Add-Content .\ADGroup_log.txt $msg
}

Function CreateUser {
    param(
        [Parameter(Mandatory=$true)][String]$counter
    )
    $new_user_name = "Test User$counter"
    try {
        Write-Host "Creating new user: $new_user_name"
        $user = New-AzADUser -DisplayName "Test User$counter" -Password $securepassword -ForceChangePasswordNextLogin -UserPrincipalName Testuser$counter@erezs80outlook.onmicrosoft.com -MailNickname Testuser$counter
        Write-Host "Successfully created new user: $new_user_name"
        return $user
    }
    catch {
        Write-Host "An error occurred:"
        Write-Host $_
        Write-Host "Failed to create a new user: $new_user_name"
        return
    }
    
}

Function AddToGroup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    
    param(
        [Parameter(Mandatory=$true, Position = 0)][PSObject]$user,
        [Parameter(Mandatory=$true, Position = 1)][PSObject]$ADGroup
    )
    $userName = $user.DisplayName
    $userPrincipalName = $user.UserPrincipalName
    $ADGroupName = $ADGroup.DisplayName
    $ADGroupId = $ADGroup.Id
    try {
        Write-Host "Adding $userName to $ADGroupName"
        Add-AzADGroupMember -MemberUserPrincipalName $userPrincipalName -TargetGroupObjectId $ADGroupId -ErrorAction Stop
        filter timestamp {"$(Get-Date -Format G) $_"}
        $timestamp = timestamp
        Write-Host "$userName successfully added to $ADGroupName at $timestamp"
        Log "$userName successfully added to $ADGroupName at $timestamp"
        return $true
       }
    catch {
        Write-Host "An error occurred:"
        Write-Host $_
        filter timestamp {"$(Get-Date -Format G) $_"}
        $timestamp = timestamp
        Write-Host "$userName Failed to be added to $ADGroupName at $timestamp"
        Log "$userName Failed to be added to $ADGroupName at $timestamp"
        return $false
    }
}


# Create a new aad security group named "Varonis Assignment Group" if one is not exist
$ADGroup = Get-AzADGroup -DisplayName $ADGroupName
if($ADGroup -eq $null) {
    $ADGroup = New-AzADGroup -DisplayName $ADGroupName -MailNickname "VaronisAssignment"
 }

# Check if there are already Test Users in aad to set the initial counter
$lastCounter = 0
$users = (Get-AzADUser -StartsWith "Test User").DisplayName
foreach($usr in $users) {
    $usrCounter = [int]($usr.split("r")[1])
    #$lastCounter += $usrCounter
    if($usrCounter -gt $lastCounter) {
        $lastCounter = $usrCounter
    }
}
#$lastCounter = $lastCounter | sort
$counter = $($lastCounter + 1) # Defination of the initial counter for the test users
$finelCounter = $($counter + 20)

# Create 20 new test users and add them to the AD security group
while($counter -ne $finelCounter) {
    $user = CreateUser $counter
    $counter++
    $i = 0
    $added = $false
    while(-not $added -and $i -le $retries) {
        $added = AddToGroup -user $user -ADGroup $ADGroup
        Start-Sleep -Seconds ($i * 5)
        $i++
    }
       
}



