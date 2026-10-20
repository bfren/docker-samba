use std/assert
use bf


#======================================================================================================================
# installation
#======================================================================================================================

export def install__samba_matches_build [] {
    let build = with-env {BF_ETC: "/etc/bf"} { bf build | get Samba }
    let installed = ^smbd --version | parse --regex 'Version (?<v>\d+\.\d+\.\d+)' | get v.0

    assert ($build | str starts-with $installed) $"Samba ($installed) should match the build ($build)"
}

export def install__tools_are_installed [] {
    for x in [smbd smbpasswd smbclient testparm] {
        assert (which $x | is-not-empty) $"($x) should be installed"
    }
}


#======================================================================================================================
# scripts
#======================================================================================================================

export def scripts__parse [] {
    let paths = [
        "/etc/bf/health.d/10-samba.nu"
        "/etc/s6-overlay/s6-rc.d/smb/run"
        "/etc/s6-overlay/s6-rc.d/smb/finish"
        "/etc/bf/init.d/11-users.nu"
        "/etc/bf/init.d/12-smb-conf.nu"
    ]
    for path in $paths {
        let result = ^$nu.current-exe --no-config-file --commands $"nu-check ($path)" | complete
        assert equal "true" ($result.stdout | str trim) $"($path) does not parse: ($result.stderr)"
    }
}
