// Configuration - Dynamic backend URL
function getBackendURL() {
    const hostname = window.location.hostname;
    const protocol = window.location.protocol;

    // Local development
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
        return 'http://localhost:8000';
    }

    // Lightning.ai pattern: PORT-STUDIOID.cloudspaces.litng.ai
    if (hostname.includes('.cloudspaces.litng.ai')) {
        // Replace port 3000 with 8000 in the hostname
        const backendHostname = hostname.replace(/^3000-/, '8000-');
        return `${protocol}//${backendHostname}`;
    }

    // Default: same hostname, different port
    return `${protocol}//${hostname}:8000`;
}

const API_URL = getBackendURL();
console.log('Backend URL:', API_URL);

// Global instances
let sceneManager;
let avatarController;
let audioPlayer;
let currentAudioFile = null;

// DOM elements
const audioFileInput = document.getElementById('audio-file');
const processBtn = document.getElementById('process-btn');
const playBtn = document.getElementById('play-btn');
const stopBtn = document.getElementById('stop-btn');
const statusMessage = document.querySelector('.status-message');
const progressBar = document.querySelector('.progress-bar');
const progressFill = document.querySelector('.progress-fill');

// Initialize
async function init() {
    console.log('🚀 Starting Audio2Face MVP...');

    // Run health checks first
    updateStatus('Running system health checks', true);
    const healthResults = await healthChecker.runAll();
    const summary = healthChecker.getSummary();

    console.log('📊 Health Check Summary:', summary);

    // Display critical failures
    if (!summary.healthy) {
        const failedChecks = healthResults.failed.map(f => f.name).join(', ');
        updateStatus(`✗ Critical errors: ${failedChecks}. Check console for details.`);
        console.error('Cannot start application due to critical errors.');
        return;
    }

    // Show warnings if any
    if (summary.warnings > 0) {
        console.warn(`⚠️ ${summary.warnings} non-critical warnings. Application will continue with limited functionality.`);
    }

    // Initialize 3D scene
    updateStatus('Initializing 3D scene', true);
    try {
        sceneManager = new SceneManager('canvas-container');
        avatarController = new AvatarController(sceneManager);
        audioPlayer = new AudioPlayer(avatarController);
        console.log('✓ 3D scene initialized');
    } catch (error) {
        updateStatus('✗ Failed to initialize 3D scene: ' + error.message);
        console.error('Scene initialization error:', error);
        return;
    }

    // Load avatar (if available)
    const avatarCheck = [...healthResults.passed, ...healthResults.warnings, ...healthResults.failed]
        .find(r => r.name === 'Avatar File');

    if (avatarCheck && avatarCheck.passed) {
        try {
            console.log('Loading avatar...');
            updateStatus('Loading avatar', true);
            await avatarController.loadAvatar('assets/avatar.glb');
            console.log('✓ Avatar loaded successfully');
        } catch (error) {
            console.error('Avatar loading error:', error);
            console.log('Continuing without avatar...');
        }
    } else {
        console.warn('Skipping avatar loading (file not found)');
    }

    // Final status
    const sdkCheck = [...healthResults.passed, ...healthResults.warnings, ...healthResults.failed]
        .find(r => r.name === 'Audio2Face SDK');

    if (sdkCheck && !sdkCheck.passed) {
        updateStatus('⚠️ Ready (SDK not initialized - audio processing unavailable)');
        console.warn('To enable audio processing, build the SDK following the documentation.');
    } else if (summary.warnings > 0) {
        updateStatus(`✓ Ready with ${summary.warnings} warning(s). Check console for details.`);
    } else {
        updateStatus('✓ All systems operational! Load an audio file to begin.');
    }

    console.log('✅ Initialization complete!');
}

// Event listeners
audioFileInput.addEventListener('change', (e) => {
    const file = e.target.files[0];
    if (file) {
        currentAudioFile = file;
        processBtn.disabled = false;
        updateStatus(`Audio file selected: ${file.name}`);
    }
});

processBtn.addEventListener('click', () => processAudio());
playBtn.addEventListener('click', () => playAnimation());
stopBtn.addEventListener('click', () => stopAnimation());

// Process audio
async function processAudio() {
    if (!currentAudioFile) return;

    processBtn.disabled = true;
    playBtn.disabled = true;
    console.log('Starting audio processing for:', currentAudioFile.name);

    // Check SDK status first
    try {
        updateStatus('Checking SDK status', true);
        const healthResponse = await fetch(`${API_URL}/health`);
        const healthData = await healthResponse.json();

        if (!healthData.sdk_loaded) {
            updateStatus('✗ SDK not initialized. Please build the Audio2Face SDK first.');
            console.error('SDK is not loaded. Cannot process audio.');
            processBtn.disabled = false;
            return;
        }
    } catch (error) {
        updateStatus('✗ Cannot connect to backend.');
        console.error('Backend connection error:', error);
        processBtn.disabled = false;
        return;
    }

    updateStatus('Processing audio... This may take a moment', true);
    showProgress();

    try {
        console.log('Uploading audio file...');
        const formData = new FormData();
        formData.append('file', currentAudioFile);

        console.log('Calling process-audio endpoint...');
        const response = await fetch(`${API_URL}/process-audio`, {
            method: 'POST',
            body: formData
        });

        console.log('Response status:', response.status);

        if (!response.ok) {
            const errorData = await response.json().catch(() => null);
            const errorMsg = errorData?.detail || `Server error: ${response.status}`;
            throw new Error(errorMsg);
        }

        const result = await response.json();
        console.log('Processing result:', result);

        if (result.success) {
            console.log('Fetching blendshape names...');
            // Store blendshape data
            const blendshapeNames = await fetchBlendshapeNames();
            avatarController.setBlendshapeData({
                blendshapes: result.data.blendshapes,
                timestamps: result.data.timestamps,
                fps: result.data.fps,
                names: blendshapeNames
            });

            // Set audio file for playback
            audioPlayer.setAudioFile(currentAudioFile);

            // Update UI
            document.getElementById('fps').textContent = result.data.fps;
            document.getElementById('frame-count').textContent = result.data.num_frames;
            document.getElementById('duration').textContent = result.data.duration.toFixed(2) + 's';

            updateStatus('✓ Processing complete! Ready to play animation.');
            console.log('Processing completed successfully!');
            playBtn.disabled = false;
            stopBtn.disabled = false;
        } else {
            throw new Error('Processing failed');
        }

    } catch (error) {
        updateStatus('✗ Error: ' + error.message);
        console.error('Processing error:', error);
    } finally {
        hideProgress();
        processBtn.disabled = false;
    }
}

// Fetch blendshape names
async function fetchBlendshapeNames() {
    const response = await fetch(`${API_URL}/blendshape-names`);
    const data = await response.json();
    return data.blendshape_names;
}

// Play animation
function playAnimation() {
    if (audioPlayer.isReady()) {
        audioPlayer.play();
        updateStatus('▶ Playing animation...');
        playBtn.disabled = true;
        processBtn.disabled = true;
    }
}

// Stop animation
function stopAnimation() {
    audioPlayer.stop();
    updateStatus('⏹ Animation stopped.');
    playBtn.disabled = false;
    processBtn.disabled = false;
}

// Update status message
function updateStatus(message, isProcessing = false) {
    statusMessage.textContent = message;
    if (isProcessing) {
        statusMessage.classList.add('processing');
    } else {
        statusMessage.classList.remove('processing');
    }
}

// Show/hide progress bar
let progressInterval = null;

function showProgress() {
    progressBar.style.display = 'block';
    animateProgress();
}

function hideProgress() {
    if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
    }
    progressBar.style.display = 'none';
    progressFill.style.width = '0%';
}

function animateProgress() {
    let width = 0;
    let increasing = true;

    // Smooth pulsing animation to show system is alive
    progressInterval = setInterval(() => {
        if (increasing) {
            width += 2;
            if (width >= 85) {
                increasing = false;
            }
        } else {
            width -= 1;
            if (width <= 60) {
                increasing = true;
            }
        }
        progressFill.style.width = width + '%';
    }, 100);
}

// Start application after THREE.js addons are ready
if (typeof THREE !== 'undefined' && THREE.OrbitControls && THREE.GLTFLoader) {
    // Addons already loaded
    init();
} else {
    // Wait for addons to load
    console.log('⏳ Waiting for THREE.js addons to load...');
    window.addEventListener('three-addons-ready', () => {
        console.log('✓ THREE.js addons ready, starting app...');
        init();
    });
}
