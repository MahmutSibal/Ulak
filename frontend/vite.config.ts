import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: [['babel-plugin-react-compiler']],
      },
    }),
  ],
  server: {
    host: true,
    port: 5173,
    strictPort: true,
    // When exposing the dev server via tunnels (e.g., ngrok), Vite may block the Host header.
    // Allow ngrok domains so you can open https://xxxx.ngrok-free.app in a remote browser.
    allowedHosts: ['.ngrok-free.app', '.ngrok.app'],
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
      '/health': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
    },
  },
})
