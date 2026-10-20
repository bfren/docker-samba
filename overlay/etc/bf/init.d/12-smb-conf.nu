use bf
use bf-samba
use bf-s6
bf env load

# Add shares to Samba configuration
def main [] {
    # load shares definitions
    let shares = bf-samba shares load

    # generate main Samba configuration file
    bf-s6 esh template (bf env SAMBA_CONF)

    # add shares
    bf write "Adding shares."
    let templates = bf env ETC_TEMPLATES
    let conf = bf env SAMBA_CONF
    for share in ($shares | get shares) {
        bf write debug $" .. ($share.name)"
        bf-samba conf share $share $templates | $"(char newline)($in)(char newline)" | save --append $conf
    }
}
