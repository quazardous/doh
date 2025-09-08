const path = require('path');
const webpack = require('webpack');
const Dotenv = require('dotenv-webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = (env, argv) => {
  const isDevelopment = argv.mode === 'development';
  const isTest = process.env.NODE_ENV === 'test';

  return {
    entry: './src/index.js',
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: isDevelopment ? '[name].js' : '[name].[contenthash].js',
      clean: true,
    },
    mode: argv.mode || 'development',
    devtool: isDevelopment ? 'eval-source-map' : 'source-map',
    
    module: {
      rules: [
        {
          test: /\.(js|jsx)$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: ['@babel/preset-env', '@babel/preset-react'],
            },
          },
        },
        {
          test: /\.css$/,
          use: ['style-loader', 'css-loader'],
        },
        {
          test: /\.(png|svg|jpg|jpeg|gif)$/i,
          type: 'asset/resource',
        },
      ],
    },
    
    plugins: [
      // Load environment variables from .env file
      new Dotenv({
        path: isTest ? './.env.test' : './.env',
        safe: true, // Check against .env.example
        systemvars: true, // Load system environment variables
        silent: false, // Suppress errors
        defaults: true, // Load .env.defaults
        prefix: 'process.env.', // Prefix for replacement
      }),
      
      // Make process.env available in browser
      new webpack.DefinePlugin({
        'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
        'process.env.API_URL': JSON.stringify(process.env.API_URL || 'http://localhost:8000'),
        'process.env.APP_NAME': JSON.stringify(process.env.APP_NAME || '{{PROJECT_NAME}}'),
      }),
      
      new HtmlWebpackPlugin({
        template: './public/index.html',
        inject: true,
      }),
    ],
    
    resolve: {
      extensions: ['.js', '.jsx', '.json'],
      alias: {
        '@': path.resolve(__dirname, 'src'),
      },
    },
    
    devServer: {
      static: {
        directory: path.join(__dirname, 'public'),
      },
      hot: true,
      port: 3000,
      proxy: {
        '/api': {
          target: process.env.API_URL || 'http://localhost:8000',
          changeOrigin: true,
        },
      },
      historyApiFallback: true,
    },
  };
};