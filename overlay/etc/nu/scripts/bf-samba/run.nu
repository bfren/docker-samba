use bf

# Run preflight checks before executing process
export def preflight [] {
    # load environment
    bf env load

    # manually set executing script
    bf env x_set --override run samba

    # if we get here we are ready to start Samba
    bf write "Starting Samba in foreground mode."
}
