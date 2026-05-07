import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'


// to wymagało zmiany, żeby ominąć problem z CORS na początku
// https://vite.dev/config/
// export default defineConfig({
//   plugins: [react()],
// })

export default defineConfig({
    plugins: [react()],
    server: {
        proxy: {
            "/api": {
                target: "http://localhost:3000",
                changeOrigin: true,
                rewrite: (path) => path.replace(/^\/api/, "")
            }
        }
    }
})
