// Load environment variables from .env file
require('dotenv').config();

const express = require('express');
const app = express();

// HTTP Hello World
app.get('/hello', (req, res) => {
  res.json({ 
    message: 'Hello World from {{PROJECT_NAME}}',
    timestamp: new Date().toISOString(),
    project: process.env.PROJECT_NAME || '{{PROJECT_NAME}}',
    stack: 'Node.js + Express',
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/', (req, res) => {
  res.redirect('/hello');
});

app.get('/health', (req, res) => {
  res.json({ status: 'OK', uptime: process.uptime() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ {{PROJECT_NAME}} server running on port ${PORT}`);
  console.log(`🌐 Access at: https://app.{{PROJECT_NAME}}.localhost`);
  console.log(`🔧 Environment: ${process.env.NODE_ENV || 'development'}`);
});