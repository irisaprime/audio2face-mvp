# Avatar Assets

## Ready Player Me Avatar

This directory should contain your Ready Player Me avatar in GLB format.

### How to Get an Avatar

1. Visit: https://readyplayer.me/
2. Create a free account
3. Customize your avatar (appearance, clothing, etc.)
4. Download the avatar in **GLB format**
5. Save it as `avatar.glb` in this directory

### File Requirements

- **Format**: GLB (GL Transmission Format Binary)
- **Size**: Typically 5-20 MB
- **Features**: Should include morph targets (blendshapes) for facial animation

### Avatar Specifications

Ready Player Me avatars come with ARKit-compatible morph targets including:
- Eye movements (blink, look)
- Jaw movements (open, close)
- Mouth shapes (various visemes)
- Eyebrow movements
- Cheek movements

### Alternative Avatars

You can also use custom GLB avatars as long as they include ARKit blendshape morph targets with standard naming conventions.

### Testing

To verify your avatar works:
1. Place `avatar.glb` in this directory
2. Start the frontend server
3. Open http://localhost:3000
4. Check browser console (F12) for "✓ Avatar loaded successfully"
5. Look for morph targets in console logs

---

**Note**: The avatar file is not included in the repository due to size and licensing. Each user should create and download their own avatar.
