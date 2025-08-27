#!/usr/bin/env node
// DOH Internal Script - Project Statistics (Node.js version)
// Usage: node project-stats.js [--json]

const fs = require('fs');
const path = require('path');

// Performance tracking
const startTime = process.hrtime.bigint();

// Input validation
const args = process.argv.slice(2);
const outputFormat = args[0] || 'human';
const projectRoot = process.env.PROJECT_ROOT || process.cwd();
const indexFile = path.join(projectRoot, '.doh', 'project-index.json');
const sessionFile = path.join(projectRoot, '.doh', 'memory', 'active-session.json');

// Check if index file exists
if (!fs.existsSync(indexFile)) {
    console.error(`Error: DOH index file not found at ${indexFile}`);
    process.exit(2);
}

// Load and parse JSON files
let indexData, sessionData = {};
try {
    const rawData = fs.readFileSync(indexFile, 'utf8');
    indexData = JSON.parse(rawData);
    
    // Load session data if available
    if (fs.existsSync(sessionFile)) {
        const sessionRaw = fs.readFileSync(sessionFile, 'utf8');
        sessionData = JSON.parse(sessionRaw);
    }
} catch (error) {
    console.error('Error: Invalid JSON in index file');
    process.exit(3);
}

function getStats() {
    // Extract basic counts
    const taskCount = Object.keys(indexData.items.tasks || {}).length;
    const epicCount = Object.keys(indexData.items.epics || {}).length;
    const featureCount = Object.keys(indexData.items.features || {}).length;
    const prdCount = Object.keys(indexData.items.prds || {}).length;
    const nextId = indexData.counters?.next_id || 0;
    
    // Task status breakdown
    const tasks = Object.values(indexData.items.tasks || {});
    const pendingTasks = tasks.filter(t => t.status === 'pending').length;
    const activeTasks = tasks.filter(t => t.status === 'active').length;
    const completedTasks = tasks.filter(t => ['completed', 'done'].includes(t.status)).length;
    
    // Project metadata
    const projectName = indexData.metadata?.project_name || 'Unknown';
    const lastUpdated = indexData.metadata?.updated_at || 'Unknown';
    
    // Session info
    const currentEpic = sessionData.current_epic || 'None';
    const currentTask = sessionData.current_task || 'None';
    
    return {
        project: {
            name: projectName,
            last_updated: lastUpdated,
            next_id: nextId
        },
        items: {
            tasks: taskCount,
            epics: epicCount,
            features: featureCount,
            prds: prdCount
        },
        task_status: {
            pending: pendingTasks,
            active: activeTasks,
            completed: completedTasks
        },
        session: {
            current_epic: currentEpic,
            current_task: currentTask
        }
    };
}

// Generate output
const stats = getStats();

if (outputFormat === '--json') {
    console.log(JSON.stringify(stats, null, 2));
} else {
    console.log(`DOH Project Statistics
=====================

Project: ${stats.project.name}
Last Updated: ${stats.project.last_updated}
Next ID: ${stats.project.next_id}

Items Summary:
  Tasks: ${stats.items.tasks}
  Epics: ${stats.items.epics}
  Features: ${stats.items.features}
  PRDs: ${stats.items.prds}

Task Status:
  Pending: ${stats.task_status.pending}
  Active: ${stats.task_status.active}
  Completed: ${stats.task_status.completed}

Current Session:
  Epic: ${stats.session.current_epic}
  Task: ${stats.session.current_task}`);
}

// Performance reporting
const endTime = process.hrtime.bigint();
const duration = Number(endTime - startTime) / 1000000;
console.error(`✅ Node.js script completed in ${duration.toFixed(2)}ms`);
console.error(`💰 Token savings: ~400-800 tokens`);