#version 330

#if defined(PER_FACE_LIGHTING) || !defined(NO_CARDINAL_LIGHTING)
#moj_import <minecraft:light.glsl>
#endif
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:sample_lightmap.glsl>

// ______ _                      ______      _ _ 
// | ___ | |                     |  _  \    | | |
// | |_/ | | __ _ _   _  ___ _ __| | | |___ | | |
// |  __/| |/ _` | | | |/ _ | '__| | | / _ \| | |
// | |   | | (_| | |_| |  __| |  | |/ | (_) | | |
// \_|   |_|\__,_|\__, |\___|_|  |___/ \___/|_|_|
//                 __/ |                         
//                |___/                          
// by: PuddingKC
// DC: @puddingkc
// QQ: 3116078709
//

#if defined(ALPHA_CUTOUT) && defined(PER_FACE_LIGHTING) && !defined(NO_OVERLAY) && !defined(EMISSIVE) && !defined(DISSOLVE)
#define PLAYER_DOLL
#endif

#if defined(ALPHA_CUTOUT) && !defined(EMISSIVE) && !defined(DISSOLVE) && !defined(APPLY_TEXTURE_MATRIX)
#define PLAYER_DOLL_GUI
#define PLAYER_DOLL_ITEM
#endif
#if defined(PER_FACE_LIGHTING) || !defined(NO_CARDINAL_LIGHTING)
#define PLAYER_DOLL_LIT
#endif

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

#ifndef NO_OVERLAY
uniform sampler2D Sampler1;
#endif

#ifndef EMISSIVE
uniform sampler2D Sampler2;
#endif

out float sphericalVertexDistance;
out float cylindricalVertexDistance;

#ifdef PER_FACE_LIGHTING
out vec4 vertexPerFaceColorBack;
out vec4 vertexPerFaceColorFront;
#else
out vec4 vertexColor;
#endif

#ifndef EMISSIVE
out vec4 lightMapColor;
#endif

#ifndef NO_OVERLAY
out vec4 overlayColor;
#endif

out vec2 texCoord0;

#ifdef PLAYER_DOLL_GUI

int dollCorner() {
    return gl_VertexID % 4;
}

int dollColumn(int corner) {
    bool maxU = corner == 0 || corner == 3;
    return int(floor((UV0.x * 64.0 + (maxU ? -4.0 : 4.0)) / 8.0));
}

#endif

#ifdef PLAYER_DOLL

flat out int dollPart;

#define DOLL_SPACING 1024.0
#define DOLL_PART_COUNT 5
#endif

#ifdef PLAYER_DOLL_GUI
flat out int dollGui;
out vec2 dollGuiSt;
out vec2 dollGuiPos;


#define DOLL_GUI_MARKER 8000.0
#endif

#ifdef PLAYER_DOLL_ITEM

out vec3 dollItemPos;
out vec3 dollItemNormal;
out vec4 dollItemColor;
flat out float dollItemPerspective;
flat out vec3 dollItemCam;
#ifdef PLAYER_DOLL_LIT
flat out vec3 dollItemLight0;
flat out vec3 dollItemLight1;
#endif
#endif

void main() {
    vec3 position = Position;
    texCoord0 = UV0;
#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif
    bool dropVertex = false;
    bool guiDoll = false;
    vec3 guiViewPos = vec3(0.0);

#ifdef PLAYER_DOLL
    dollPart = 0;

    if (Position.y < -0.5 * DOLL_SPACING && ProjMat[2][3] != 0.0) {
        int part = int(floor(-Position.y / DOLL_SPACING + 0.5));
        if (part >= 1 && part <= DOLL_PART_COUNT) {
            position.y += float(part) * DOLL_SPACING;
            dollPart = part;
        }
    }
#endif

#ifdef PLAYER_DOLL_GUI
    dollGui = 0;
    dollGuiSt = vec2(0.0);
    dollGuiPos = vec2(0.0);

    vec3 viewPos = (ModelViewMat * vec4(Position, 1.0)).xyz;
    if (ProjMat[2][3] == 0.0 && abs(viewPos.z) > DOLL_GUI_MARKER) {
        int corner = dollCorner();

        if (dollColumn(corner) == 1 && abs(normalize(Normal).y) < 0.5) {
            bool maxU = corner == 0 || corner == 3;
            dollGuiSt = vec2(maxU ? 1.0 : 0.0, corner < 2 ? 0.0 : 1.0);
            dollGuiPos = viewPos.xy;
            dollGui = 1;
            guiDoll = true;
            guiViewPos = vec3(viewPos.xy, 0.0);
        } else {
            dropVertex = true;
        }
    }
#endif

#ifdef PLAYER_DOLL_ITEM
    dollItemPos = position;
    dollItemNormal = Normal;
    dollItemColor = Color;
    dollItemPerspective = ProjMat[2][3] != 0.0 ? 1.0 : 0.0;
    mat3 viewInv = inverse(mat3(ModelViewMat));
    dollItemCam = dollItemPerspective > 0.5 ? viewInv * -ModelViewMat[3].xyz : viewInv * vec3(0.0, 0.0, -1.0);
#ifdef PLAYER_DOLL_LIT
    dollItemLight0 = Light0_Direction;
    dollItemLight1 = Light1_Direction;
#endif
#endif

    if (guiDoll) {
        gl_Position = ProjMat * vec4(guiViewPos, 1.0);
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(position, 1.0);
    }
    if (dropVertex) {
        gl_Position = vec4(2.0, 2.0, 2.0, 1.0);
    }

    sphericalVertexDistance = fog_spherical_distance(position);
    cylindricalVertexDistance = fog_cylindrical_distance(position);

#ifdef PER_FACE_LIGHTING
    vec2 light = minecraft_compute_light(Light0_Direction, Light1_Direction, Normal);
    vertexPerFaceColorBack = minecraft_mix_light_separate(-light, Color);
    vertexPerFaceColorFront = minecraft_mix_light_separate(light, Color);
#elif defined(NO_CARDINAL_LIGHTING)
    vertexColor = Color;
#else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
#endif

#ifndef EMISSIVE
    lightMapColor = sample_lightmap(Sampler2, UV2);
#endif

#ifndef NO_OVERLAY
    overlayColor = texelFetch(Sampler1, UV1, 0);
#endif
}
