function Get-QlikUser {
  [CmdletBinding()]
  param (
    [parameter(Position=0,ValueFromPipelinebyPropertyName=$true)]
    [string]$id,
    [string]$filter,
    [switch]$full,
    [switch]$raw
  )

  PROCESS {
    $path = "/qrs/user"
    If( $id ) { $path += "/$id" }
    If( $full ) { $path += "/full" }
    If( $raw ) { $rawOutput = $true }
    $result = Invoke-QlikGet $path $filter
    if( $raw -Or $full ) {
      return $result
    } else {
      $properties = @('name','userDirectory','userId')
      #if( $full ) { $properties += @('roles','inactive','blacklisted','removedExternally') }
      return $result | select -Property $properties
    }
  }
}

function New-QlikUser {
  [CmdletBinding()]
  param (
    [string]$userId,
    [string]$userDirectory,
    [string]$name = $userId,
    [string[]]$roles
  )

  PROCESS {
    $user = @{
      userId=$userId;
      userDirectory=$userDirectory;
      name=$name
    }
    if($roles) { $user.roles = $roles }
    $json = $user | ConvertTo-Json -Compress -Depth 10

    return Invoke-QlikPost "/qrs/user" $json
  }
}

function Remove-QlikUser {
  [CmdletBinding()]
  param (
    [parameter(Position=0,ValueFromPipelinebyPropertyName=$true)]
    [string]$id
  )

  PROCESS {
    return Invoke-QlikDelete "/qrs/user/$id"
  }
}

function Update-QlikUser {
  [CmdletBinding()]
  param (
    [parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,Position=0)]
    [string]$id,

    [string[]]$customProperties,
    [string[]]$tags,
    [string]$name,
    [string[]]$roles
  )

  PROCESS {
    $user = Get-QlikUser $id -raw
    If( $roles ) { $user.roles = $roles }
    If( $name ) { $user.name = $name }
    If( $customProperties ) {
      $user.customProperties = @(GetCustomProperties $customProperties)
    }
    If( $tags ) {
      $user.tags = GetTags $tags
    }
    $json = $user | ConvertTo-Json -Compress -Depth 10
    return Invoke-QlikPut "/qrs/user/$id" $json
  }
}
