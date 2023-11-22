use bf

# Load shares definition file
export def load [] {
    # if shares definition file does not exist, throw an error
    let shares = bf env SAMBA_SHARES
    if ($shares | bf fs is_not_file) { bf write error $"You must create ($shares) - see samba-conf-sample.json." shares/load }

    # open the shares file and return data
    open $shares
}
