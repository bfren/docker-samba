use bf
use bf-samba
bf env load

# Add system and Samba users from the shares defition file
def main [] {
    # add Samba user if it does not already exist
    if not (bf user exists samba) { bf user add --uid (bf env SAMBA_UID 1000) samba }

    # load shares definitions
    let shares = bf-samba shares load
    bf write "Adding users."
    for $user in ($shares | get users) {
        # if the user already exists, move on
        if (bf user exists $user.name) { continue }

        # we need to add a system user account first, but the password is managed by Samba
        {
            bf write debug $" .. ($user.name)"
            ^adduser -D $user.name
            $"($user.pass)\n($user.pass)" | ^smbpasswd -a $user.name
        } | bf handle
    }
}
