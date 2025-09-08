<?php

// Load environment variables from .env file
require_once __DIR__ . '/../vendor/autoload.php';

$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

// Simple router for Hello World
$requestUri = $_SERVER['REQUEST_URI'];
$requestMethod = $_SERVER['REQUEST_METHOD'];

if ($requestMethod === 'GET') {
    switch ($requestUri) {
        case '/':
        case '/hello':
            handleHello();
            break;
        case '/health':
            handleHealth();
            break;
        default:
            http_response_code(404);
            echo json_encode(['error' => 'Not found']);
            break;
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}

function handleHello() {
    header('Content-Type: application/json');
    echo json_encode([
        'message' => 'Hello World from {{PROJECT_NAME}}',
        'timestamp' => date('c'),
        'project' => $_ENV['PROJECT_NAME'] ?? '{{PROJECT_NAME}}',
        'stack' => 'PHP + nginx',
        'environment' => $_ENV['APP_ENV'] ?? 'development',
        'php_version' => PHP_VERSION
    ]);
}

function handleHealth() {
    header('Content-Type: application/json');
    echo json_encode([
        'status' => 'OK',
        'uptime' => getUptime(),
        'memory_usage' => memory_get_usage(true),
        'peak_memory' => memory_get_peak_usage(true)
    ]);
}

function getUptime() {
    // Simple uptime simulation (would be more complex in real app)
    return round(microtime(true) - $_SERVER['REQUEST_TIME_FLOAT'], 2) . ' seconds';
}