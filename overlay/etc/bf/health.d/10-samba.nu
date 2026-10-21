use bf
bf env load -x

# Attempt to list shares on localhost
def main [] {
    let args = [
        "-L" "localhost"
        "-U" "%"
        "-m" "SMB3"
    ]
    if ({ ^smbclient ...$args } | bf handle -c) != 0 { exit 1 }
}
