use std/assert
use bf-samba


#======================================================================================================================
# helpers
#======================================================================================================================

# Generate the configuration for a share, and return its lines with spaces trimmed
def share [definition: record]: nothing -> list<string> {
    bf-samba conf share $definition /etc/bf/templates | lines | str trim | where {|x| $x != "" }
}

# Generate smb.conf from the template in a temporary directory, with $vars set, and return its settings
def render [vars: record = {}]: nothing -> list<string> {
    let file = $"(mktemp --directory)/smb.conf"
    let result = with-env $vars { ^esh -o $file /etc/bf/templates/smb.conf.esh | complete }
    assert equal 0 $result.exit_code $"the template should render: ($result.stderr)"
    open --raw $file | lines | str trim | where {|x| $x != "" and not ($x starts-with "#") and not ($x starts-with ";") }
}


#======================================================================================================================
# yes_or_no
#======================================================================================================================

export def yes_or_no__defaults_to_yes [] {
    assert equal "yes" (bf-samba conf yes_or_no)
    assert equal "yes" (bf-samba conf yes_or_no null)
}

export def yes_or_no__converts_values [] {
    assert equal "yes" (bf-samba conf yes_or_no true)
    assert equal "no" (bf-samba conf yes_or_no false)
}


#======================================================================================================================
# is_public
#======================================================================================================================

export def is_public__when_users_include_star [] {
    assert (bf-samba conf is_public {name: "a", users: ["*"]})
    assert not (bf-samba conf is_public {name: "a", users: ["fred"]})
    assert not (bf-samba conf is_public {name: "a"})
}


#======================================================================================================================
# share
#======================================================================================================================

export def share__limits_access_to_users [] {
    let conf = share {name: "docs", comment: "Documents", users: ["fred" "jones"]}

    assert equal "[docs]" ($conf | first)
    for x in ["comment = Documents" "path = /files/docs" "valid users = fred jones" "force user = samba"] {
        assert ($x in $conf) $"($x) should be set"
    }
}

export def share__is_browseable_and_writeable_by_default [] {
    let conf = share {name: "docs", users: ["fred"]}

    assert ("browsable = yes" in $conf)
    assert ("writable = yes" in $conf)
}

export def share__uses_browseable_and_writeable [] {
    let conf = share {name: "docs", users: ["fred"], browseable: false, writeable: false}

    assert ("browsable = no" in $conf)
    assert ("writable = no" in $conf)
}

export def share__public_allows_guests [] {
    let conf = share {name: "public", users: ["*"]}

    assert equal "[public]" ($conf | first)
    for x in ["path = /files/public" "public = yes" "only guest = yes" "force user = samba"] {
        assert ($x in $conf) $"($x) should be set"
    }
    assert ($conf | where {|x| $x starts-with "valid users" } | is-empty)
}


#======================================================================================================================
# smb.conf
#======================================================================================================================

export def smb_conf__uses_defaults [] {
    let conf = render

    for x in ["workgroup = WORKGROUP" "server string = Samba Server" "server role = standalone server" "map to guest = bad user"] {
        assert ($x in $conf) $"($x) should be set"
    }
    assert ($conf | where {|x| $x starts-with "netbios aliases" } | is-empty)
}

export def smb_conf__has_no_home_or_printer_shares [] {
    let conf = render

    assert equal ["[global]"] ($conf | where {|x| $x starts-with "[" })
    for x in ["load printers = no" "disable spoolss = yes"] {
        assert ($x in $conf) $"($x) should be set"
    }
}

export def smb_conf__uses_settings [] {
    let conf = render {BF_SAMBA_WORKGROUP: "HOME", BF_SAMBA_SERVER: "Files", BF_SAMBA_NETBIOS_ALIAS: "files"}

    for x in ["workgroup = HOME" "server string = Files" "netbios aliases = files"] {
        assert ($x in $conf) $"($x) should be set"
    }
}


#======================================================================================================================
# shares
#======================================================================================================================

export def shares__fail_without_definition_file [] {
    let file = $"(mktemp --directory)/shares.json"

    assert error { with-env {BF_SAMBA_SHARES: $file} { bf-samba shares load } }
}

export def shares__load_definition_file [] {
    let file = $"(mktemp --directory)/shares.json"
    {users: [{name: "fred", pass: "secret"}], shares: [{name: "docs", users: ["fred"]}]} | to json | save $file

    let result = with-env {BF_SAMBA_SHARES: $file} { bf-samba shares load }

    assert equal "fred" $result.users.0.name
    assert equal "docs" $result.shares.0.name
}
