{
    split($0,a,"/")
    split(a[3],b,":")
    date2conv = a[1]" "a[2]" "b[1]" "b[2]":"b[3]":"b[4]
    cmd = "date --date=\""date2conv"\" +%s\"\""
    cmd | getline seconds
    print seconds
}
