#!/usr/bin/env bash
#
# Helper script to compare our syscall blacklist against upstream firejail one

src_sbox='https://raw.githubusercontent.com/netblue30/firejail/refs/heads/master/src/firejail/sbox.c'
src_secondary='https://raw.githubusercontent.com/netblue30/firejail/refs/heads/master/src/fseccomp/seccomp_secondary.c'
bl_sbox=/tmp/"$(basename $src_sbox)"
bl_secondary=/tmp/"$(basename $src_secondary)"
bl_bsafe="../syscall_blacklist.inc.sh"
parsed_bl_tmp=/tmp/seccomp_bl_tmp.log
parsed_bl_firejail=/tmp/seccomp_bl_fj.log
parsed_bl_bsafe=/tmp/seccomp_bl_my.log

cd -- "$(dirname -- "$( realpath -- "${BASH_SOURCE[0]}" )")" &> /dev/null || true

# Download source files from firejail git repo when they don't exist
! [[ -r "$bl_sbox" ]] && wget "$src_sbox" -O "$bl_sbox"
! [[ -r "$bl_secondary" ]] && wget "$src_secondary" -O "$bl_secondary"

# Parse syscall entities from three different formats
awk -F' // ' '/BLACKLIST/ {print $2}' "$bl_secondary" > "$parsed_bl_tmp"
sed -n 's/.*(SYS_\([^)]*\)).*/\1/p' "$bl_sbox" >> "$parsed_bl_tmp"
sed 's/^[ ]*\([a-z0-9_]*\).*/\1/p' "$bl_bsafe"|sort -u > "$parsed_bl_bsafe"
sort -u "$parsed_bl_tmp" > "$parsed_bl_firejail"

printf 'Missing in bsafe_blacklist:\n\n'
comm -13 "$parsed_bl_bsafe" "$parsed_bl_firejail"
printf '\nUnique in bsafe_blacklist:\n\n'
comm -23 "$parsed_bl_bsafe" "$parsed_bl_firejail"

rm "$parsed_bl_bsafe" "$parsed_bl_firejail" "$parsed_bl_tmp"
