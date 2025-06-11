#!/usr/bin/env bash
#
# small helper script to lookup blocked system calls in dmesg and print them by name
#
# Possibly you need to run it as root in case you can't call dmesg as user.
# Use `dmesg -C` to clear the log

# Change directory to where bsafe is located
if ! cd -- "$(dirname -- "$( realpath -- "${BASH_SOURCE[0]}" )")" &> /dev/null;then
  echo "Failed to change to script directory"
  exit 1
fi

dmesg | awk '
BEGIN {
    # Load syscall names into array
    while ((getline line < "signallist_value-name.csv") > 0) {
        split(line, parts, ";")
        names[parts[1]] = parts[2]
    }
    close("signallist_value-name.csv")
}
/syscall/ && match($0, /syscall=([0-9]+)/, arr) {
    syscalls[arr[1]] = 1  # Track unique syscalls
}
END {
    # Print unique syscall names in sorted order
    # PROCINFO["sorted_in"] = "@ind_num_asc"
    for (num in syscalls) {
        if (num in names) print names[num]
        else print "Unknown: " num
    }
}'

