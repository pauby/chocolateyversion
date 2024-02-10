class ChocolateyVersion : System.IComparable {
    [int]   $Major = 0
    [int]   $Minor = 0
    [int]   $Patch = 0
    [int]   $Revision = -1

    # See this GitHub issue https://github.com/PowerShell/PowerShell/issues/7294
    # assigning $null to the strings doesn't make any difference, they are still set to empty strings (tested in PS Core 7.3.6).
    # Using [NullString]::Value seems to do the job.
    [string]$PreRelease = [NullString]::Value
    [string]$Build = [NullString]::Value

    ChocolateyVersion ([string]$Version) {
        # Borrowed from https://github.com/maxhauser/semver/blob/v2.3.0/Semver/SemVersion.cs#L43-L48
        $versionRegex = "^(?<major>\d+)(?>\.(?<minor>\d+))?(?>\.(?<patch>\d+))?(?>\.(?<revision>\d+))?(?>\-(?<prerelease>[0-9A-Za-z\-\.]+))?(?>\+(?<build>[0-9A-Za-z\-\.]+))?$"

        if ($Version -match $versionRegex) {
            'major', 'minor', 'patch', 'revision', 'prerelease', 'build' | ForEach-Object {
                if ($matches.$($_)) {
                    # We need the first 3 parts, ALWAYS. If revision (the 4th part) is 0, just ignore it.
                    if ($_ -eq 'revision' -and [int]($matches.$($_)) -eq 0) {
                        $this.$_ = -1
                    }
                    else {
                        $this.$_ = $matches.$_
                    }
                }
            }
        }
        else {
            throw "Cannot parse $Version. Is it a valid ChocolateyVersion?"
        }
    }

    [string] ToString () {
        # I used a loop here and things go complex so kept it simple and used multiple if's

        # the first three parts must have values for a Chocolatey Version

        # $this.Major will always have a value
        $versionString = "$($this.Major)"

        if ($this.Minor -ne -1) {
            $versionString += ".$($this.Minor)"
        }
        else {
            $versionString += ".0"
        }

        if ($this.Patch -ne -1) {
            $versionString += ".$($this.Patch)"
        }
        else {
            $versionString += ".0"
        }

        if ($this.Revision -ne -1) {
            $versionString += ".$($this.Revision)"
        }

        if ($null -ne $this.PreRelease) {
            $versionString += "-$($this.PreRelease)"
        }

        if ($null -ne $this.Build) {
            $versionString += "+$($this.Build)"
        }

        return $versionString
    }

    [string] hidden ToVersionTypeString () {
        # I used a loop here and things go complex so kept it simple and used multiple if's

        # the first three parts must have values for a Chocolatey Version

        # $this.Major will always have a value
        $versionString = "$($this.Major)"

        if ($this.Minor -ne -1) {
            $versionString += ".$($this.Minor)"
        }
        else {
            $versionString += ".0"
        }

        if ($this.Patch -ne -1) {
            $versionString += ".$($this.Patch)"
        }
        else {
            $versionString += ".0"
        }

        if ($this.Revision -ne -1) {
            $versionString += ".$($this.Revision)"
        }

        return $versionString
    }

    # Custom-define -eq / -ne, by overriding Object.Equals()
    # Note that I don't think we need a GetHashCode method here.
    # https://stackoverflow.com/questions/59290037/overloading-operator-in-powershell-classes/59294529#59294529
    [bool] Equals([object] $Other) {

        # We can't just use the version strings for comparison, as they will not be normalized.
        # For example, '1.2.3' is the same as '1.2.00003' in version number, but not as a string.
        # The prelease and build we CAN compare as a string
        [version]$thisVersion = [version]($this.ToVersionTypeString())
        [version]$otherVersion = [version]($other.ToVersionTypeString())

        # first compare the [version] objects and if they are the same compare the prerelease and build.
        if ($thisVersion -eq $otherVersion) {
            if (($this.PreRelease -eq $other.PreRelease) -and ($this.Build -eq $other.Build)) {
                # everything matches so these are the same
                return $true
            }
            else {
                return $false
            }
        }
        else {
            return $false
        }
    }

    # Custom-define -lt / -le and -gt / -ge, via the System.IComparable interface.
    # See https://stackoverflow.com/questions/59290037/overloading-operator-in-powershell-classes/59294529#59294529
    # if it's equal, should return 0
    # -lt should return -1
    # gt should return 1
    [int] CompareTo([object] $Other) {

        # lets check if they are equal first of all
        if ($this.Equals($Other)) {
            return 0
        }
        
        # if we get here, the versions are not equal
        [version]$thisVersion = [version]($this.ToString())
        [version]$otherVersion = [version]($other.ToString())
        $thisVersionExtra = "$($this.PreRelease)+$($this.Build)"
        $otherVersionExtra = "$($other.PreRelease)+$($other.Build)"

        if ($thisVersion -eq $otherVersion) {
            if ($thisVersionExtra -eq $otherVersionExtra) {
                return 0
            }
            elseif ($thisVersionExtra -lt $otherVersionExtra) {
                return -1
            }
            else {
                return 1
            }
        }
        elseif ($thisversion -lt $otherVersion) {
            return -1
        }
        else {
            return 1
        }
    }
}