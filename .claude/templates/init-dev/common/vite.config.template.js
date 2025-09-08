import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ command, mode }) => {
  // Load env file based on `mode` in the current working directory.
  // Set the third parameter to '' to load all env regardless of the `VITE_` prefix.
  const env = loadEnv(mode, process.cwd(), '');
  
  // For test environment, load .env.test
  if (mode === 'test') {
    Object.assign(process.env, loadEnv('test', process.cwd(), ''));
  }

  return {
    plugins: [react()],
    
    // Define global constants
    define: {
      'process.env.API_URL': JSON.stringify(env.API_URL || 'http://localhost:8000'),
      'process.env.APP_NAME': JSON.stringify(env.APP_NAME || '{{PROJECT_NAME}}'),
      'process.env.NODE_ENV': JSON.stringify(mode),
    },
    
    resolve: {
      alias: {
        '@': '/src',
      },
    },
    
    server: {
      port: 3000,
      host: true,
      proxy: {
        '/api': {
          target: env.API_URL || 'http://localhost:8000',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ''),
        },
      },
    },
    
    build: {
      outDir: 'dist',
      sourcemap: mode !== 'production',
      rollupOptions: {
        output: {
          manualChunks: {
            vendor: ['react', 'react-dom'],
          },
        },
      },
    },
    
    test: {
      environment: 'jsdom',
      setupFiles: './src/test/setup.js',
      coverage: {
        reporter: ['text', 'html'],
        reportsDirectory: './var/coverage',
      },
    },
  };
});