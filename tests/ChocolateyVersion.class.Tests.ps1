BeforeAll {
    # get the folder parent folder name - public or private
    $scopeName = Split-Path -Path (Split-Path -Path ($PSCommandPath) -Parent) -Leaf
    $fileName = Split-Path -Path ($PSCommandPath.Replace('.Tests.ps1', '.ps1')) -Leaf

    . ../../src/$scopeName/$filename
}

Describe "ChocolateyVersion Class" {
    It "should return <expectedString> and have an object to match when version is <version>" -ForEach @(
        @{ version = '1'; expectedString = '1.0.0'; expectedObject = @{ Major = 1; Minor = 0; Patch = 0; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '1.8'; expectedString = '1.8.0'; expectedObject = @{ Major = 1; Minor = 8; Patch = 0; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '1.6.9'; expectedString = '1.6.9'; expectedObject = @{ Major = 1; Minor = 6; Patch = 9; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '1.0.0.0'; expectedString = '1.0.0'; expectedObject = @{ Major = 1; Minor = 0; Patch = 0; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '8.31.0.0'; expectedString = '8.31.0'; expectedObject = @{ Major = 8; Minor = 31; Patch = 0; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '19.0.3.0'; expectedString = '19.0.3'; expectedObject = @{ Major = 19; Minor = 0; Patch = 3; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '4.0.0.74'; expectedString = '4.0.0.74'; expectedObject = @{ Major = 4; Minor = 0; Patch = 0; Revision = 74; PreRelease = $null; Build = $null } }
        @{ version = '2390.0.0.4'; expectedString = '2390.0.0.4'; expectedObject = @{ Major = 2390; Minor = 0; Patch = 0; Revision = 4; PreRelease = $null; Build = $null } }
        @{ version = '008.00.00'; expectedString = '8.0.0'; expectedObject = @{ Major = 8; Minor = 0; Patch = 0; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '0010.00.00'; expectedString = '10.0.0'; expectedObject = @{ Major = 10; Minor = 0; Patch = 0; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '007.004.0'; expectedString = '7.4.0'; expectedObject = @{ Major = 7; Minor = 4; Patch = 0; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '0010.0020.0'; expectedString = '10.20.0'; expectedObject = @{ Major = 10; Minor = 20; Patch = 0; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '005.003.009'; expectedString = '5.3.9'; expectedObject = @{ Major = 5; Minor = 3; Patch = 9; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '0040.0030.030'; expectedString = '40.30.30'; expectedObject = @{ Major = 40; Minor = 30; Patch = 30; Revision = -1; PreRelease = $null; Build = $null } }
        @{ version = '002.004.09.08'; expectedString = '2.4.9.8'; expectedObject = @{ Major = 2; Minor = 4; Patch = 9; Revision = 8; PreRelease = $null; Build = $null } }
        @{ version = '0060.0030.080.00900'; expectedString = '60.30.80.900'; expectedObject = @{ Major = 60; Minor = 30; Patch = 80; Revision = 900; PreRelease = $null; Build = $null } }
        @{ version = '12-beta1+18.9.8'; expectedString = '12.0.0-beta1+18.9.8'; expectedObject = @{ Major = 12; Minor = 0; Patch = 0; Revision = -1; PreRelease = 'beta1'; Build = '18.9.8' } }
        @{ version = '6.3-beta.4+14.18.22'; expectedString = '6.3.0-beta.4+14.18.22'; expectedObject = @{ Major = 6; Minor = 3; Patch = 0; Revision = -1; PreRelease = 'beta.4'; Build = '14.18.22' } }
        @{ version = '2.6.9-beta1+230'; expectedString = '2.6.9-beta1+230'; expectedObject = @{ Major = 2; Minor = 6; Patch = 9; Revision = -1; PreRelease = 'beta1'; Build = '230' } }
        @{ version = '6.3.8.9-alpha.15+12.4'; expectedString = '6.3.8.9-alpha.15+12.4'; expectedObject = @{ Major = 6; Minor = 3; Patch = 8; Revision = 9; PreRelease = 'alpha.15'; Build = '12.4' } }
    ) { 
        $result = [ChocolateyVersion]$version
        $result.ToString() | Should -Be $expectedString
        $result.Major | Should -Be $expectedObject.Major
        $result.Minor | Should -Be $expectedObject.Minor
        $result.Patch | Should -Be $expectedObject.Patch
        $result.Revision | Should -Be $expectedObject.Revision
        $result.PreRelease | Should -Be $expectedObject.PreRelease
        $result.Build | Should -Be $expectedObject.Build

        $result = [ChocolateyVersion]::New($version)
        $result.ToString() | Should -Be $expectedString
        $result.Major | Should -Be $expectedObject.Major
        $result.Minor | Should -Be $expectedObject.Minor
        $result.Patch | Should -Be $expectedObject.Patch
        $result.Revision | Should -Be $expectedObject.Revision
        $result.PreRelease | Should -Be $expectedObject.PreRelease
        $result.Build | Should -Be $expectedObject.Build
    }

    It "should return <expected> when version <version> equals <comparison>" -ForEach @(
        @{ version = '1'; comparison = '1'; expected = $true }
        @{ version = '7'; comparison = '7.0'; expected = $true }
        @{ version = '4'; comparison = '4.0.0'; expected = $true }
        @{ version = '6'; comparison = '6.0.0.0'; expected = $true }
        @{ version = '5.0'; comparison = '5'; expected = $true }
        @{ version = '8.0.0'; comparison = '8'; expected = $true }
        @{ version = '3.0.0.0'; comparison = '3'; expected = $true }
        @{ version = '6.0'; comparison = '6.0'; expected = $true }
        @{ version = '7.0.0'; comparison = '7.0.0'; expected = $true }
        @{ version = '14.0.0.0'; comparison = '14.0.0.0'; expected = $true }
        @{ version = '2.98.6-beta5+10.10.10'; comparison = '2.98.6-beta5+10.10.10'; expected = $true }
        @{ version = '07.0800'; comparison = '07.800'; expected = $true }
        @{ version = '1'; comparison = '1.1'; expected = $false }
        @{ version = '7'; comparison = '7.0.0-beta.6'; expected = $false }
        @{ version = '5.3.0-beta.6'; comparison = '5.3.0-beta.6+23.9'; expected = $false }
    ) {        
        [ChocolateyVersion]$version -eq [ChocolateyVersion]$comparison | Should -Be $expected

        $v = [ChocolateyVersion]::new($version)
        $c = [ChocolateyVersion]::new($comparison)
        $v -eq $c | Should -Be $expected
    }

    It "should return `$true when comparing version <version> with <comparison>" -ForEach @(
        @{ version = '1'; comparison = '1.1' }
        @{ version = '7'; comparison = '7.0.0-beta.6' }
        @{ version = '5.3.0-beta.6'; comparison = '5.3.0-beta.6+23.9' }
    ) {        
        [ChocolateyVersion]$version -lt [ChocolateyVersion]$comparison | Should -BeTrue
    }
}