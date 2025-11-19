class AudioPlayer {
    constructor(avatarController) {
        this.avatarController = avatarController;
        this.audio = null;
        this.isPlaying = false;
        this.animationFrameId = null;
        this.startTime = 0;
    }

    setAudioFile(file) {
        const url = URL.createObjectURL(file);
        this.audio = new Audio(url);
        this.audio.addEventListener('ended', () => this.stop());
    }

    play() {
        if (!this.audio || !this.avatarController.blendshapeData) {
            console.error('No audio or blendshape data loaded');
            return;
        }

        this.isPlaying = true;
        this.startTime = Date.now();
        this.audio.play();

        this.animate();
    }

    animate() {
        if (!this.isPlaying) return;

        const currentTime = (Date.now() - this.startTime) / 1000;
        const data = this.avatarController.blendshapeData;

        // Find current frame based on timestamp
        const frameIndex = Math.floor(currentTime * data.fps);

        if (frameIndex < data.blendshapes.length) {
            this.avatarController.applyBlendshapes(frameIndex);
            this.animationFrameId = requestAnimationFrame(() => this.animate());
        } else {
            this.stop();
        }
    }

    stop() {
        this.isPlaying = false;
        if (this.audio) {
            this.audio.pause();
            this.audio.currentTime = 0;
        }
        if (this.animationFrameId) {
            cancelAnimationFrame(this.animationFrameId);
        }
        this.avatarController.reset();
    }

    isReady() {
        return this.audio !== null && this.avatarController.blendshapeData !== null;
    }
}
