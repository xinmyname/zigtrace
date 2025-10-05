# Copilot Instructions for zigtrace

## Project Overview
This is a Zig WebAssembly raytracer that renders to HTML5 canvas via JavaScript interop. The architecture separates compute (Zig/WASM) from presentation (JS/Vite), with a custom build pipeline that compiles Zig to WASM and copies it to `public/` for Vite to serve.

## Versions
This project uses the following versions of development tools and languages. All generated code should be compatible with these versions.
* Vite v7.1.x
* Zig v0.15.x
* Node.js v22.x

## Critical Build & Development Workflow

### Build Command
```bash
zig build
```
This compiles `src/main.zig` to `zig-out/bin/main.wasm` and copies it to `public/main.wasm` via a custom `CopyWasmStep` in `build.zig`.

### Dev Server
```bash
npm run dev
```
Runs Vite dev server with a custom `watchWasmReloadPlugin` that watches `public/main.wasm` for changes and triggers full-reload (not HMR).

### Standard Development Loop
1. Edit Zig code in `src/`
2. Run `zig build` to compile and copy WASM
3. Vite detects `public/main.wasm` change and auto-reloads browser

## Architecture Patterns

### WASM Target Configuration
All Zig code targets `wasm32-freestanding` (see `build.zig`):
- `entry = .disabled` - no _start function
- `rdynamic = true` - export symbols for JS
- `import_memory = true` - JS provides WebAssembly.Memory
- `optimize = .ReleaseSmall` - size optimization for web delivery

### JS ↔ Zig Interop
Communication happens through two channels:

**Zig calling JS** (`src/JS.zig`):
```zig
pub extern fn consoleLog(ptr: [*]const u8, len: usize) void;
pub extern fn renderLine(line: u32, ptr: [*]const u8, len: usize) void;
```
These are imported functions provided by `importObject.env` in `src/main.js`.

**JS calling Zig** (`src/main.js`):
```javascript
resultObject.instance.exports.render(canvas.width, canvas.height);
```
Functions marked `pub export` in Zig become WASM exports accessible from JS.

### Memory Management
- Use `std.heap.wasm_allocator` for all allocations (see `src/main.zig`)
- Shared memory buffer: JS creates `WebAssembly.Memory`, Zig imports it
- Pass data via pointer+length pairs (no copying across boundary)
- Example: `render()` allocates line buffer, fills it, passes pointer to JS

### Console Logging Pattern
Use `Console.log()` (wraps `std.fmt.bufPrint` + JS interop) instead of `std.debug.print`:
```zig
Console.log("Rendering {} x {} ...", .{ width, height });
```
This ensures output appears in browser devtools, not stderr.

## File Naming & Structure Conventions
- Zig modules use PascalCase filenames: `Vec3.zig`, `Console.zig`, `JS.zig`
- Import with `@import("ModuleName.zig")` - exact filename match required
- Use `@This()` pattern for defining structs in their own files (see `Vec3.zig`, `Console.zig`)

## Testing
Run Zig unit tests (e.g., in `Vec3.zig`):
```bash
zig test src/Vec3.zig
```
Tests use standard library `std.testing` framework.

Where possible, zig code should include unit tests for all non-trivial functions and methods.

## Common Gotchas
- Changes to `build.zig` require rebuilding, not just running `zig build` again
- WASM stack is limited (`stack_size = std.wasm.page_size`), but may be expanded if necessary.
- Vite custom plugin requires `apply: 'serve'` to only run in dev mode, not build mode
- Memory Configuration: The `WebAssembly.Memory` in `main.js` is configured with `initial: 2, maximum: 64` pages (128KB-4MB). If you get out-of-memory errors, you need to increase these values (each page = 64KB)
