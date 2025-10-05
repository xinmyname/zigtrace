import { defineConfig } from 'vite';

// Custom plugin to watch the generated WASM file sitting in public/ so a rebuild triggers a full reload.
function watchWasmReloadPlugin() {
  const wasmRelPath = 'public/main.wasm';
  return {
    name: 'watch-wasm-reload',
    apply: 'serve', // only needed for dev
    configureServer(server) {
      const { watcher, ws } = server;
      // Ensure the file is watched explicitly (public/ assets aren't in module graph)
      watcher.add(wasmRelPath);

      let reloadTimer = null;
      watcher.on('change', (changedPath) => {
        if (!changedPath.endsWith('main.wasm')) return;
        // Debounce in case build writes multiple times quickly
        if (reloadTimer) clearTimeout(reloadTimer);
        reloadTimer = setTimeout(() => {
          console.log(`[watch-wasm-reload] Detected change in ${changedPath}; sending full-reload`);
          ws.send({ type: 'full-reload', path: '/' });
        }, 40);
      });
    },
  };
}

export default defineConfig({
  plugins: [watchWasmReloadPlugin()],
  // Optional: tweak server watch to be more responsive if desired
  server: {
    watch: {
      // Use polling only if native FS events have issues; commented out by default.
      // usePolling: true,
      // interval: 100,
    },
  },
});
