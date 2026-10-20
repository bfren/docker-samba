use bf

# Return 'yes' or 'no' for a share setting - the default (when not set) is 'yes'
export def yes_or_no [
    input?: any # The value of the setting
]: nothing -> string {
    let result = if ($input | is-empty) { true } else { $input | into bool }
    if $result { "yes" } else { "no" }
}

# Returns true if a share is public - its users include '*'
export def is_public [
    share: record   # Share definition
]: nothing -> bool {
    "*" in ($share.users? | default [])
}

# Generate the configuration for a share, using the public or share template
export def share [
    share: record       # Share definition
    templates: string   # Templates directory
]: nothing -> string {
    let name = $share.name
    let comment = $share.comment? | default ""

    if (is_public $share) {
        with-env {NAME: $name, COMMENT: $comment} { bf esh $"($templates)/public.esh" }
    } else {
        let vars = {
            NAME: $name
            COMMENT: $comment
            USERS: ($share.users? | default [] | str join " ")
            BROWSEABLE: (yes_or_no $share.browseable?)
            WRITEABLE: (yes_or_no $share.writeable?)
        }
        with-env $vars { bf esh $"($templates)/share.esh" }
    }
}
