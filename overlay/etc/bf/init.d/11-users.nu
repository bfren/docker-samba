use bf
use bf-samba
bf env load

# Add system and Samba users from the shares defition file
def main [] {
    # add Samba user if it does not already exist
    if not (user_exists samba) { bf user add --uid (bf env SAMBA_UID 1000) samba }

    # load shares definitions
    let shares = bf-samba shares load
    bf write "Adding users."
    for $user in ($shares | get users) {
        # if the user already exists, move on
        if (user_exists $user.name) { continue }

        # we need to add a system user account first, but the password is managed by Samba
        {
            bf write debug $" .. ($user.name)"
            ^adduser -D $user.name
            ^echo -e $"($user.pass)\n($user.pass)" | ^smbpasswd -a $user.name
        } | bf handle
    }
}

# Returns true if user $name is found in the passwd file
def user_exists [
    name: string    # User name to search
] {
    (open "/etc/passwd" | find $name | length) > 0
}
