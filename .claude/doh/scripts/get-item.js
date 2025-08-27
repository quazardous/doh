#!/usr/bin/env node
// DOH Internal Script - Get Item Details (Node.js version)
// Usage: node get-item.js <item_id> [item_type]

const fs = require('fs');
const path = require('path');

// Performance tracking
const startTime = process.hrtime.bigint();

// Input validation
const args = process.argv.slice(2);
if (args.length < 1) {
    console.error('Usage: node get-item.js <item_id> [item_type]');
    process.exit(1);
}

const itemId = args[0];
const itemType = args[1] || 'auto';
const projectRoot = process.env.PROJECT_ROOT || process.cwd();
const indexFile = path.join(projectRoot, '.doh', 'project-index.json');

// Check if index file exists
if (!fs.existsSync(indexFile)) {
    console.error(`Error: DOH index file not found at ${indexFile}`);
    process.exit(2);
}

// Load and parse JSON
let indexData;
try {
    const rawData = fs.readFileSync(indexFile, 'utf8');
    indexData = JSON.parse(rawData);
} catch (error) {
    console.error('Error: Invalid JSON in index file');
    process.exit(3);
}

function getItemByType(id, type) {
    const typeMap = {
        'task': 'tasks',
        'tasks': 'tasks',
        'epic': 'epics', 
        'epics': 'epics',
        'feature': 'features',
        'features': 'features',
        'prd': 'prds',
        'prds': 'prds'
    };
    
    const normalizedType = typeMap[type];
    if (!normalizedType) {
        console.error(`Error: Unknown item type: ${type}`);
        process.exit(1);
    }
    
    return indexData.items[normalizedType]?.[id] || null;
}

function getItemAuto(id) {
    const types = ['tasks', 'epics', 'features', 'prds'];
    
    for (const type of types) {
        const item = indexData.items[type]?.[id];
        if (item) {
            return { ...item, item_type: type };
        }
    }
    
    return null;
}

// Main logic
let result;
if (itemType === 'auto') {
    result = getItemAuto(itemId);
    if (!result) {
        console.error(`Error: Item with ID '${itemId}' not found`);
        process.exit(4);
    }
} else {
    result = getItemByType(itemId, itemType);
    if (!result) {
        console.error(`Error: ${itemType} with ID '${itemId}' not found`);
        process.exit(4);
    }
    result.item_type = itemType;
}

// Output result
console.log(JSON.stringify(result, null, 2));

// Performance reporting
const endTime = process.hrtime.bigint();
const duration = Number(endTime - startTime) / 1000000; // Convert to milliseconds
console.error(`✅ Node.js script completed in ${duration.toFixed(2)}ms`);
console.error(`💰 Token savings: ~300-500 tokens`);