// Automated Health Check for Frontend
// This script validates all dependencies and services before initializing

class HealthCheck {
    constructor() {
        this.checks = [];
        this.results = {
            passed: [],
            failed: [],
            warnings: []
        };
    }

    // Add a check to the queue
    addCheck(name, checkFn, critical = true) {
        this.checks.push({ name, checkFn, critical });
    }

    // Run all checks
    async runAll() {
        console.log('🏥 Running health checks...');

        for (const check of this.checks) {
            try {
                const result = await check.checkFn();
                if (result.passed) {
                    this.results.passed.push({ name: check.name, ...result });
                    console.log(`✓ ${check.name}: PASSED`);
                } else {
                    if (check.critical) {
                        this.results.failed.push({ name: check.name, ...result });
                        console.error(`✗ ${check.name}: FAILED - ${result.message}`);
                    } else {
                        this.results.warnings.push({ name: check.name, ...result });
                        console.warn(`⚠ ${check.name}: WARNING - ${result.message}`);
                    }
                }
            } catch (error) {
                const errorResult = { name: check.name, passed: false, message: error.message, error };
                if (check.critical) {
                    this.results.failed.push(errorResult);
                    console.error(`✗ ${check.name}: ERROR - ${error.message}`);
                } else {
                    this.results.warnings.push(errorResult);
                    console.warn(`⚠ ${check.name}: WARNING - ${error.message}`);
                }
            }
        }

        return this.results;
    }

    // Get summary report
    getSummary() {
        return {
            total: this.checks.length,
            passed: this.results.passed.length,
            failed: this.results.failed.length,
            warnings: this.results.warnings.length,
            healthy: this.results.failed.length === 0
        };
    }

    // Display results in UI
    displayResults(statusElement) {
        const summary = this.getSummary();

        if (summary.healthy) {
            if (summary.warnings > 0) {
                statusElement.textContent = `⚠️ System ready with ${summary.warnings} warning(s). Check console.`;
            } else {
                statusElement.textContent = '✓ All systems operational!';
            }
        } else {
            statusElement.textContent = `✗ ${summary.failed} critical issue(s) found. Check console.`;
        }
    }
}

// Create health checker instance
const healthChecker = new HealthCheck();

// Check 1: THREE.js library loaded
healthChecker.addCheck('THREE.js Library', async () => {
    if (typeof THREE !== 'undefined') {
        return { passed: true, version: THREE.REVISION };
    }
    return {
        passed: false,
        message: 'THREE.js not loaded. Check CDN links in index.html',
        fix: 'Ensure <script src="https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.min.js"></script> is loaded'
    };
}, true);

// Check 2: GLTFLoader available
healthChecker.addCheck('GLTFLoader', async () => {
    if (typeof THREE.GLTFLoader !== 'undefined') {
        return { passed: true };
    }
    return {
        passed: false,
        message: 'GLTFLoader not available',
        fix: 'Check GLTFLoader script tag in index.html'
    };
}, false);

// Check 3: OrbitControls available
healthChecker.addCheck('OrbitControls', async () => {
    if (typeof THREE.OrbitControls !== 'undefined') {
        return { passed: true };
    }
    return {
        passed: false,
        message: 'OrbitControls not available',
        fix: 'Check OrbitControls script tag in index.html'
    };
}, false);

// Check 4: Backend connectivity
healthChecker.addCheck('Backend API', async () => {
    try {
        const response = await fetch('http://localhost:8000/health', {
            signal: AbortSignal.timeout(5000)
        });
        const data = await response.json();

        return {
            passed: response.ok,
            status: data.status,
            sdkLoaded: data.sdk_loaded
        };
    } catch (error) {
        return {
            passed: false,
            message: 'Cannot connect to backend. Is it running?',
            fix: 'Start backend with: make run-backend'
        };
    }
}, true);

// Check 5: SDK Status
healthChecker.addCheck('Audio2Face SDK', async () => {
    try {
        const response = await fetch('http://localhost:8000/health');
        const data = await response.json();

        if (data.sdk_loaded) {
            return { passed: true, message: 'SDK is initialized' };
        }

        return {
            passed: false,
            message: 'SDK not initialized. Audio processing unavailable.',
            fix: 'Build SDK: cd Audio2Face-3D-SDK && cmake --build _build'
        };
    } catch (error) {
        return { passed: false, message: 'Cannot check SDK status' };
    }
}, false);

// Check 6: Avatar file
healthChecker.addCheck('Avatar File', async () => {
    try {
        const response = await fetch('assets/avatar.glb', { method: 'HEAD' });
        if (response.ok) {
            const size = response.headers.get('content-length');
            return {
                passed: true,
                size: size ? `${(size / 1024 / 1024).toFixed(2)} MB` : 'unknown'
            };
        }
        return {
            passed: false,
            message: 'Avatar file not found',
            fix: 'Download avatar from https://readyplayer.me/ and save as assets/avatar.glb'
        };
    } catch (error) {
        return {
            passed: false,
            message: 'Cannot access avatar file',
            fix: 'Download avatar from https://readyplayer.me/ and save as assets/avatar.glb'
        };
    }
}, false);

// Export for use in app.js
window.HealthCheck = HealthCheck;
window.healthChecker = healthChecker;
