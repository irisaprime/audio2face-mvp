class AvatarController {
    constructor(sceneManager) {
        this.sceneManager = sceneManager;
        this.avatar = null;
        this.morphTargets = null;
        this.blendshapeData = null;
        this.isLoaded = false;
    }

    async loadAvatar(url) {
        return new Promise((resolve, reject) => {
            const loader = new THREE.GLTFLoader();

            loader.load(
                url,
                (gltf) => {
                    this.avatar = gltf.scene;
                    this.avatar.position.set(0, 0, 0);

                    // Find mesh with morph targets (usually the head)
                    this.avatar.traverse((child) => {
                        if (child.isMesh && child.morphTargetInfluences) {
                            this.morphTargets = child;
                            console.log('Found morph targets:',
                                child.morphTargetDictionary);
                        }
                    });

                    this.sceneManager.add(this.avatar);
                    this.isLoaded = true;

                    console.log('✓ Avatar loaded successfully');
                    resolve();
                },
                (progress) => {
                    const percent = (progress.loaded / progress.total * 100).toFixed(0);
                    console.log(`Loading avatar: ${percent}%`);
                },
                (error) => {
                    console.error('✗ Failed to load avatar:', error);
                    reject(error);
                }
            );
        });
    }

    setBlendshapeData(data) {
        this.blendshapeData = data;
    }

    applyBlendshapes(frameIndex) {
        if (!this.morphTargets || !this.blendshapeData) return;

        const blendshapes = this.blendshapeData.blendshapes[frameIndex];
        const names = this.blendshapeData.names;

        // Apply each blendshape
        for (let i = 0; i < blendshapes.length && i < names.length; i++) {
            const name = names[i];
            const value = blendshapes[i];

            // Map Audio2Face blendshape to Ready Player Me
            const morphIndex = this.morphTargets.morphTargetDictionary[name];

            if (morphIndex !== undefined) {
                this.morphTargets.morphTargetInfluences[morphIndex] = value;
            }
        }
    }

    reset() {
        if (!this.morphTargets) return;

        // Reset all morph targets to 0
        for (let i = 0; i < this.morphTargets.morphTargetInfluences.length; i++) {
            this.morphTargets.morphTargetInfluences[i] = 0;
        }
    }
}
