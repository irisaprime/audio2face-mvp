// Configuration
const API_URL = 'http://localhost:8000';

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
    updateStatus('Initializing 3D scene...');

    // Create scene
    sceneManager = new SceneManager('canvas-container');
    avatarController = new AvatarController(sceneManager);
    audioPlayer = new AudioPlayer(avatarController);

    // Load avatar
    try {
        await avatarController.loadAvatar('assets/avatar.glb');
        updateStatus('✓ Ready. Load an audio file to begin.');
    } catch (error) {
        updateStatus('✗ Failed to load avatar. Check console for details.');
        console.error(error);
    }
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
    updateStatus('Processing audio...');
    showProgress();

    try {
        const formData = new FormData();
        formData.append('file', currentAudioFile);

        const response = await fetch(`${API_URL}/process-audio`, {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            throw new Error(`Server error: ${response.status}`);
        }

        const result = await response.json();

        if (result.success) {
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
            playBtn.disabled = false;
            stopBtn.disabled = false;
        } else {
            throw new Error('Processing failed');
        }

    } catch (error) {
        updateStatus('✗ Error: ' + error.message);
        console.error(error);
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
function updateStatus(message) {
    statusMessage.textContent = message;
}

// Show/hide progress bar
function showProgress() {
    progressBar.style.display = 'block';
    animateProgress();
}

function hideProgress() {
    progressBar.style.display = 'none';
    progressFill.style.width = '0%';
}

function animateProgress() {
    let width = 0;
    const interval = setInterval(() => {
        if (width >= 90) {
            clearInterval(interval);
        } else {
            width += 10;
            progressFill.style.width = width + '%';
        }
    }, 200);
}

// Start application
init();
