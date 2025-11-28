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
            // Check if GLTFLoader is available
            if (typeof THREE.GLTFLoader === 'undefined') {
                console.error('GLTFLoader not available');
                reject(new Error('GLTFLoader not loaded'));
                return;
            }

            const loader = new THREE.GLTFLoader();

            // Set a timeout to prevent infinite hanging
            const timeout = setTimeout(() => {
                console.warn('Avatar loading timed out after 10 seconds');
                reject(new Error('Avatar loading timeout'));
            }, 10000);

            loader.load(
                url,
                (gltf) => {
                    clearTimeout(timeout);
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
                    if (progress.total > 0) {
                        const percent = (progress.loaded / progress.total * 100).toFixed(0);
                        console.log(`Loading avatar: ${percent}%`);
                    }
                },
                (error) => {
                    clearTimeout(timeout);
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
        if (!this.blendshapeData) return;

        const blendshapes = this.blendshapeData.blendshapes[frameIndex];
        const names = this.blendshapeData.names;

        // Debug: Log on first frame
        if (frameIndex === 0) {
            console.log('🎭 Blendshape Mapping Debug:');
            console.log('Backend blendshape names:', names.slice(0, 10));
            if (this.morphTargets) {
                console.log('Avatar morph targets:', Object.keys(this.morphTargets.morphTargetDictionary).slice(0, 10));

                let matchCount = 0;
                names.forEach(name => {
                    if (this.morphTargets.morphTargetDictionary[name] !== undefined) {
                        matchCount++;
                    }
                });
                console.log(`Matched ${matchCount} / ${names.length} blendshapes`);
            } else {
                console.log('No avatar with morph targets loaded');
            }
        }

        // Update debug panel with top blendshapes
        this.updateDebugPanel(blendshapes, names);

        // Apply to avatar if available
        if (this.morphTargets) {
            for (let i = 0; i < blendshapes.length && i < names.length; i++) {
                const name = names[i];
                const value = blendshapes[i];

                const morphIndex = this.morphTargets.morphTargetDictionary[name];
                if (morphIndex !== undefined) {
                    this.morphTargets.morphTargetInfluences[morphIndex] = value;
                }
            }
        }
    }

    updateDebugPanel(blendshapes, names) {
        const debugPanel = document.getElementById('blendshape-debug');
        const debugValues = document.getElementById('blendshape-values');

        if (!debugPanel || !debugValues) {
            console.log('❌ Debug panel elements not found:', {
                debugPanel: !!debugPanel,
                debugValues: !!debugValues
            });
            return;
        }

        // Show debug panel
        debugPanel.style.display = 'block';
        console.log('✅ Debug panel visible, updating with', names.length, 'blendshapes');

        // Get top 10 active blendshapes
        const blendshapeArray = names.map((name, i) => ({
            name: name,
            value: blendshapes[i]
        }));

        // Sort by value (highest first) and take top 10
        const topBlendshapes = blendshapeArray
            .sort((a, b) => Math.abs(b.value) - Math.abs(a.value))
            .slice(0, 10);

        // Create visualization
        let html = '<div style="padding: 5px;">';
        topBlendshapes.forEach(bs => {
            const percentage = (bs.value * 100).toFixed(1);
            const barWidth = Math.abs(bs.value) * 100;
            html += `
                <div style="margin-bottom: 3px;">
                    <div style="display: flex; justify-content: space-between;">
                        <span style="font-size: 10px;">${bs.name}</span>
                        <span style="font-size: 10px; font-weight: bold;">${percentage}%</span>
                    </div>
                    <div style="background: #ddd; height: 4px; border-radius: 2px; margin-top: 2px;">
                        <div style="background: #4CAF50; height: 4px; width: ${barWidth}%; border-radius: 2px;"></div>
                    </div>
                </div>
            `;
        });
        html += '</div>';

        debugValues.innerHTML = html;
    }

    reset() {
        if (!this.morphTargets) return;

        // Reset all morph targets to 0
        for (let i = 0; i < this.morphTargets.morphTargetInfluences.length; i++) {
            this.morphTargets.morphTargetInfluences[i] = 0;
        }
    }
}
