#!/usr/bin/env node

const path = require('path');
const fs = require('fs');

console.log('🚀 DOH Hello World - Node.js Console Script');

// Basic Hello World
console.log('✅ Console Hello World: Node.js script working!');

// Environment validation
const nodeEnv = process.env.NODE_ENV || 'development';
console.log(`Environment: ${nodeEnv}`);

// Database connectivity test (example with common ORMs)
async function testDatabase() {
    try {
        // Check if we have database configuration
        if (process.env.DATABASE_URL) {
            console.log(`✅ Database Config: ${process.env.DATABASE_URL.split('@')[0]}@[hidden]`);
            
            // If using Prisma
            if (fs.existsSync('prisma/schema.prisma')) {
                console.log('  ORM: Prisma detected');
            }
            // If using Sequelize
            else if (fs.existsSync('models/index.js')) {
                console.log('  ORM: Sequelize detected');
            }
            // If using TypeORM
            else if (fs.existsSync('ormconfig.json') || fs.existsSync('data-source.ts')) {
                console.log('  ORM: TypeORM detected');
            }
            
            console.log('✅ Database Hello World: Configuration present');
        } else {
            console.log('⚪ Database Hello World: No DATABASE_URL configured');
        }
    } catch (error) {
        console.error(`❌ Database connectivity failed: ${error.message}`);
    }
}

// Dotenv files validation
console.log('\nDotenv Files Status:');
const dotenvFiles = nodeEnv === 'test' ? ['.env', '.env.test'] : ['.env', '.env.local'];
dotenvFiles.forEach(file => {
    const status = fs.existsSync(file) ? '✅ Found' : '⚪ Optional';
    console.log(`  ${file}: ${status}`);
});

// Package.json validation
if (fs.existsSync('package.json')) {
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    console.log(`\nProject: ${pkg.name || 'unnamed'} v${pkg.version || '0.0.0'}`);
    
    // Check for DOH scripts
    const dohScripts = Object.keys(pkg.scripts || {}).filter(s => s.startsWith('doh:'));
    if (dohScripts.length > 0) {
        console.log(`DOH Scripts: ${dohScripts.join(', ')}`);
    }
}

// Run database test
testDatabase().then(() => {
    console.log('\n🎉 Node.js DOH Hello World complete!');
}).catch(error => {
    console.error(`Error: ${error.message}`);
    process.exit(1);
});