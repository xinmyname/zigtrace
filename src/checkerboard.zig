const std = @import("std");

extern fn consoleLog(arg: u32) void;

const checkerboard_size: usize = 8;

// checkerboard_size * 2, where each pixel is 4 bytes (rgba)
var checkerboard_buffer = std.mem.zeroes(
    [checkerboard_size][checkerboard_size][4]u8,
);

// The returned pointer will be used as an offset integer to the wasm memory
export fn getCheckerboardBufferPointer() [*]u8 {
    return @ptrCast(&checkerboard_buffer);
}

export fn getCheckerboardSize() usize {
    return checkerboard_size;
}

export fn colorCheckerboard(
    dark_value_red: u8,
    dark_value_green: u8,
    dark_value_blue: u8,
    light_value_red: u8,
    light_value_green: u8,
    light_value_blue: u8,
) void {
    for (&checkerboard_buffer, 0..) |*row, y| {
        for (row, 0..) |*square, x| {
            var is_dark_square = true;

            if ((y % 2) == 0) {
                is_dark_square = false;
            }

            if ((x % 2) == 0) {
                is_dark_square = !is_dark_square;
            }

            var square_value_red = dark_value_red;
            var square_value_green = dark_value_green;
            var square_value_blue = dark_value_blue;
            if (!is_dark_square) {
                square_value_red = light_value_red;
                square_value_green = light_value_green;
                square_value_blue = light_value_blue;
            }

            square.*[0] = square_value_red;
            square.*[1] = 0; //square_value_green;
            square.*[2] = 0; //square_value_blue;
            square.*[3] = 255;
        }
    }
}

// Vite dev reload tip:
// 1. Ensure the compiled wasm ends up inside the project root (e.g. src/checkerboard.wasm).
// 2. Import it so it enters the module graph:
//    import wasmUrl from './checkerboard.wasm?url';
// 3. Add this plugin to vite.config.ts to force a full page reload on .wasm change:
//
//    import { defineConfig } from 'vite';
//    export default defineConfig({
//      plugins: [{
//        name: 'reload-wasm',
//        handleHotUpdate(ctx) {
//          if (ctx.file.endsWith('.wasm')) {
//            ctx.server.ws.send({ type: 'full-reload' });
//          }
//        },
//      }],
//    });
//
// 4. Rebuild command example (write directly over the same file so watcher fires):
//    zig build-lib src/checkerboard.zig -target wasm32-freestanding -O Debug -femit-bin=src/checkerboard.wasm
//
// 5. If rename semantics prevent change detection, explicitly add:
//    server: { watch: { persistent: true } } and/or ctx.server.watcher.add('src/checkerboard.wasm') inside configureServer.
//
// 6. For cache busting (defensive):
//    const mod = await WebAssembly.instantiateStreaming(fetch(wasmUrl + '?v=' + Date.now()));
