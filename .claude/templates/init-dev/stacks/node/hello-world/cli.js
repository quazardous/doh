#!/usr/bin/env node

console.log('🎉 Hello World from {{PROJECT_NAME}} CLI');
console.log('📁 Project:', process.env.PROJECT_NAME || '{{PROJECT_NAME}}');
console.log('🕒 Timestamp:', new Date().toISOString());
console.log('🔧 Node.js version:', process.version);
console.log('🌍 Environment:', process.env.NODE_ENV || 'development');