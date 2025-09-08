#!/usr/bin/env php
<?php

// Load environment variables from .env file
require_once __DIR__ . '/../vendor/autoload.php';

$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

echo "🎉 Hello World from {{PROJECT_NAME}} CLI\n";
echo "📁 Project: " . ($_ENV['PROJECT_NAME'] ?? '{{PROJECT_NAME}}') . "\n";
echo "🕒 Timestamp: " . date('c') . "\n";
echo "🐘 PHP version: " . PHP_VERSION . "\n";
echo "🌍 Environment: " . ($_ENV['APP_ENV'] ?? 'development') . "\n";

// Show environment variables loaded from .env
$envVars = [
    'PROJECT_NAME',
    'APP_ENV',
    'DATABASE_URL',
    'APP_SECRET'
];

echo "\n🔧 Environment variables:\n";
foreach ($envVars as $var) {
    $value = $_ENV[$var] ?? 'Not set';
    // Mask sensitive values
    if (strpos($var, 'SECRET') !== false || strpos($var, 'PASSWORD') !== false || strpos($var, 'KEY') !== false) {
        $value = $value !== 'Not set' ? '***' : 'Not set';
    }
    echo "  • $var: $value\n";
}