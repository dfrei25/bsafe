#include <seccomp.h>
#include <fcntl.h>
#include <unistd.h>
#include <iostream>
#include <vector>
#include <string>
#include <cstring>

int main(int argc, char* argv[]) {
    // Check if we have at least one argument
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " [-l|-b] [syscall1] [syscall2] ...\n";
        std::cerr << "  -l: Log mode (SCMP_ACT_LOG)\n";
        std::cerr << "  -b: Block mode (SCMP_ACT_ERRNO)\n";
        return 1;
    }
    
    // Parse the first argument to determine action
    uint32_t action;
    if (strcmp(argv[1], "-l") == 0) {
        action = SCMP_ACT_LOG;
        std::cout << "Using LOG mode\n";
    } else if (strcmp(argv[1], "-b") == 0) {
        action = SCMP_ACT_ERRNO(EPERM);  // Block with permission denied error
        std::cout << "Using BLOCK mode\n";
    } else {
        std::cerr << "Invalid action flag. Use -l for log or -b for block\n";
        return 1;
    }
    
    // Collect remaining arguments (syscall names) into a vector
    std::vector<std::string> syscall_names;
    for (int i = 2; i < argc; i++) {
        syscall_names.push_back(argv[i]);
    }
    
    if (syscall_names.empty()) {
        std::cerr << "No syscalls specified\n";
        return 1;
    }
    
    // Start with ALLOW by default
    scmp_filter_ctx ctx = seccomp_init(SCMP_ACT_ALLOW);
    if (!ctx) {
        std::cerr << "Failed to init seccomp\n";
        return 1;
    }
    
    // Also allow 32 bit architectures // not having this made me a headache. `seccomp-tools disasm` had been very helpful
    seccomp_arch_add(ctx, SCMP_ARCH_X86);    // optional 32-bit ABI
    seccomp_arch_add(ctx, SCMP_ARCH_X32);    // for x32 ABI compatibility
    
    // Convert syscall names to syscall numbers and apply the action
    for (const std::string& syscall_name : syscall_names) {
        int syscall_num = seccomp_syscall_resolve_name(syscall_name.c_str());
        if (syscall_num == __NR_SCMP_ERROR) {
            std::cerr << "Warning: Unknown syscall '" << syscall_name << "', skipping\n";
            continue;
        }
        
        if (seccomp_rule_add(ctx, action, syscall_num, 0) < 0) {
            std::cerr << "Warning: Failed to add rule for syscall " << syscall_name << " (" << syscall_num << ")\n";
        }
    }
    
    // Export to file
    int fd = open("/tmp/filter.bpf", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) {
        perror("open");
        seccomp_release(ctx);
        return 1;
    }
    
    if (seccomp_export_bpf(ctx, fd) < 0) {
        std::cerr << "seccomp_export_bpf failed\n";
        close(fd);
        seccomp_release(ctx);
        return 1;
    }
    
    close(fd);
    seccomp_release(ctx);
    std::cout << "Exported filter to /tmp/filter.bpf\n";
    return 0;
}
