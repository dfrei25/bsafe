#!/usr/bin/env bash
#
# syscall_blacklist.inc.sh:  Meant to be sourced by bsafe and not executed on its own.
#
# Holds all default blacklist entities 

declare -a seccomp_blacklist=(
    # Process/execution control - prevent code injection and privilege escalation
    # execve           #  Execute programs
    # execveat         #  Execute programs (newer variant)
    ptrace             # Process tracing/debugging - can inject code
    process_vm_readv   # Read another process's memory
    process_vm_writev  # Write to another process's memory

    # mprotect         # Change memory protection - can make code executable
    # pkey_mprotect    # Memory protection with protection keys # maybe needed for jit
    # mmap             # Memory mapping - can create executable memory
    # mmap2            # Memory mapping (32-bit variant)
    remap_file_pages   #  Remap file pages - deprecated and dangerous

    # Kernel module operations - direct kernel access
    init_module        #  Load kernel module
    finit_module       #  Load kernel module from file descriptor
    delete_module      #  Unload kernel module
    create_module      #  Create kernel module (obsolete)
 
    # System configuration and privileged operations
    reboot             # Reboot system
    sethostname        #+ Set hostname
    setdomainname      #+ Set domain name
    sysfs              # Legacy, unnecessary, zero benefit in modern apps
    mount              # Mount filesystems // steam ns
    umount             # Unmount filesystems //steam ns
    umount2            # Unmount filesystems (with flags) //steam ns
    fsopen             # Introduced in Linux 5.2, replaces mount system call. Safe-ish, but can be used to mount arbitrary filesystems. 
    fsmount            # Completes a mount operation — combined with above, can fully mount filesystems.
    fsconfig           # Can specify device paths, mount options — powerful and risky in hands of an attacker.
    move_mount         # Lets users place mounts anywhere in their namespace. 
    fspick             # Read-only access to existing mounts. Harmless unless combined with move_mount()
    open_tree          # Allows duplication of entire mount trees — can be used for chroots, mount overlays, etc.
    swapon             # Enable swap
    swapoff            # Disable swap
    pivot_root         # Change root filesystem // steam namespaces break
    chroot             # Change root directory
    syslog             # Reading/writing kernel log buffer
  
    # Raw device and memory access
    ioprio_set         # Normally harmless, but can be abused to raise I/O priority, starve other processes, or trigger DoS via RT class.
    ioperm             # Set I/O port permissions
    iopl               # Set I/O privilege level
    kexec_load         # Load kernel for kexec
    kexec_file_load    # Load kernel from file for kexec
    uselib             # Load shared library (obsolete and dangerous)
  
    # Performance and debugging - can be used for information disclosure
    perf_event_open    # Performance monitoring - can leak kernel info
    quotactl           #+ Filesystem quota control
  
    # Network namespace and advanced networking
    # socket           # Can create AF_INET, AF_UNIX, AF_PACKET, etc. High risk if unrestricted.
    setns              #+ Set namespace - can escape containers
    unshare            #+ Create new namespace - privilege escalation risk // firefox needs this
  
    # BPF - can be used to bypass security measures
    bpf                #+ BPF system call - very powerful

    # Clock manipulation
    settimeofday       #+ Set system time
    adjtimex           # Adjust system clock
    clock_adjtime      # Adjust clock
    clock_settime      #+ Set clock time
  
    # # IPC that could be abused # low risk
    # msgctl             # Message queue control
    # msgget             # Get message queue
    # msgrcv             # Receive message
    # msgsnd             # Send message
    # semctl             # Semaphore control // steam
    # semget             # Get semaphore // steam
    # semop              # Semaphore operation // steam
    # semtimedop         # Timed semaphore operation // steam
    # shmctl             # Shared memory control
    # shmdt              # Detach shared memory
    # shmget             # Get shared memory
    # shmat              # Attach shared memory
  
    # Potentially dangerous file operations
    name_to_handle_at  # Get file handle - can bypass permissions
    open_by_handle_at  # Open file by handle - can bypass permissions
  
    # Keyring operations - can access sensitive keys
    add_key            # Add key to keyring
    request_key        # Request key from keyring
    keyctl             # Key management operations
 
    # NUMA operations that could be abused
    migrate_pages      # Migrate pages between NUMA nodes
    move_pages         # Move pages between NUMA nodes
    mbind # Binds memory pages to NUMA nodes; affects performance, DoS risk
    get_mempolicy # Queries NUMA policies — generally harmless, allow in HPC
    set_mempolicy # Alters NUMA policies; may influence system memory behavior
  
    # Fanotify - filesystem monitoring that could leak info
    fanotify_init      # Can monitor access to files. Powerful.
    fanotify_mark      #+ Marks files/directories for notification.
 
    # Advanced scheduling that could be abused
    sched_setattr    #+ Set scheduling attributes
    
    # AIO
    io_setup # Part of libaio; creates AIO contexts in kernel — rarely needed, kernel-resident state
    io_destroy # Destroys AIO context; part of same group
    io_getevents # Retrieves AIO completion events
    io_submit # Submits async I/O; vulnerable in old kernels
    io_cancel # Cancels pending AIO

    acct # Enables/disables process accounting; requires CAP_SYS_ADMIN
    kcmp # Compares kernel objects between processes; used in container tools
    lookup_dcookie # Used for debugging (dnotify, dcookie); not used in modern apps
    modify_ldt # Used to modify segment descriptors; legacy x86 syscall, can be abused for exploits
    personality # some personality flags disable security features (like ASLR), increasing exploitability. - possibly used in wine
    vmsplice # High risk of kernel bugs (historically exploitable); avoid unless explicitly required
    # _sysctl removed in Linux 5.5
    # ni_syscall         # It’s not actually a real syscall — it’s a handler in the syscall table that returns -ENOSYS for unknown syscalls. No risk
    # query_module       #  Removed in 2.6
    # get_kernel_syms    # removed in 2.6
    # nfsservctl         # removed in linux 3.1
    # vm86               # x86-32 only Enter virtual 8086 mode
    # vm86old            # x86-32 only Enter virtual 8086 mode (old)
    # nfsservctl         # removed in 3.1
)
