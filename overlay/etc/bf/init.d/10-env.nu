use bf
bf env load

# Set environment variables
def main [] {
    let files = "/files"
    bf env set SAMBA_FILES $files
    bf env set SAMBA_SHARES $"($files)/shares.json"

    let etc = "/etc/samba"
    bf env set SAMBA_ETC $etc
    bf env set SAMBA_CONF $"($etc)/smb.conf"

    # return nothing
    return
}
