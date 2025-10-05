const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    const root_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .ReleaseSmall,
    });

    const exe = b.addExecutable(.{
        .name = "main",
        .root_module = root_mod,
    });

    exe.entry = .disabled;
    exe.rdynamic = true;
    exe.stack_size = std.wasm.page_size;
    exe.import_memory = true;

    // Add an explicit install step for the executable so we can depend on the installed file (in zig-out/bin/...)
    const install_exe = b.addInstallArtifact(exe, .{});

    // Pure Zig copy step: copy the produced wasm into the repository `public/` folder.
    const CopyWasmStep = struct {
        step: std.Build.Step,

        pub fn create(build_ctx: *std.Build) *@This() {
            const self = build_ctx.allocator.create(@This()) catch @panic("OOM");
            self.* = .{
                .step = std.Build.Step.init(.{
                    .id = .custom,
                    .name = "copy-wasm-to-public",
                    .owner = build_ctx,
                    .makeFn = make,
                }),
            };
            return self;
        }

        fn make(_: *std.Build.Step, _: std.Build.Step.MakeOptions) anyerror!void {
            const src_path = "zig-out/bin/main.wasm"; // known output location
            const dest_path = "public/main.wasm";

            // Ensure source exists; if not, silently return (build dependency should ensure it exists).
            var src_file = std.fs.cwd().openFile(src_path, .{}) catch return; // nothing to copy yet
            defer src_file.close();

            // Log size of source wasm for visibility.
            if (src_file.stat()) |st| {
                // Use std.debug.print for broad Zig version compatibility.
                std.debug.print("copy-wasm-to-public: {s} size = {d} bytes\n", .{ src_path, st.size });
            } else |_| {}

            // Ensure destination directory exists.
            if (std.fs.path.dirname(dest_path)) |parent| try std.fs.cwd().makePath(parent);

            var dest_file = try std.fs.cwd().createFile(dest_path, .{ .truncate = true });
            defer dest_file.close();

            var buf: [16 * 1024]u8 = undefined;
            while (true) {
                const n = try src_file.read(&buf);
                if (n == 0) break;
                try dest_file.writeAll(buf[0..n]);
            }
        }
    };

    const copy_step = CopyWasmStep.create(b);
    // Ensure the wasm has been installed (placed in zig-out/bin) before we attempt to copy it.
    copy_step.step.dependOn(&install_exe.step);
    // Make overall install also run the copy.
    b.getInstallStep().dependOn(&copy_step.step);
}
