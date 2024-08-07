use bf
use bf-samba
bf env load

# Add shares to Samba configuration
def main [] {
    # load shares definitions
    let shares = bf-samba shares load

    # generate main Samba configuration file
    bf esh template (bf env SAMBA_CONF)

    # add shares
    bf write "Adding shares."
    let templates = bf env ETC_TEMPLATES
    let conf = bf env SAMBA_CONF
    for share in ($shares | get shares) {
        $share | bf dump -t "share"
        # get values for the template
        let name = $share.name | bf dump -t "name"
        let comment = $share.comment? | bf dump -t "comment"
        let users = $share.users | str join " " | bf dump -t "users"
        let browseable = yes_or_no $share.browseable? | bf dump -t "browseable"
        let writeable = yes_or_no $share.writeable? | bf dump -t "writeable"

        # if users contains * use the public template
        bf write debug $" .. ($name)"
        if "*" in $users {
            with-env { NAME: $name, COMMENT: $comment } {
                bf esh $"($templates)/public.esh" | $"(char newline)($in)(char newline)" | save --append $conf
            }
        } else {
            with-env { NAME: $name, COMMENT: $comment, USERS: $users, BROWSEABLE: $browseable, WRITEABLE: $writeable } {
                bf esh $"($templates)/share.esh" | $"(char newline)($in)(char newline)" | save --append $conf
            }
        }
    }
}

# Determine whether an input value should be 'yes' or 'no' - the default value is 'yes'
def yes_or_no [
    input?: any
] {
    let result = if ($input | is-empty) { true } else { $input | into bool }
    if $result { "yes"} else { "no" }
}
