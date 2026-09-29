#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

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

uniform sampler2D Sampler0;

#ifdef DISSOLVE
uniform sampler2D DissolveMaskSampler;
#endif

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
#ifdef PER_FACE_LIGHTING
in vec4 vertexPerFaceColorBack;
in vec4 vertexPerFaceColorFront;
#else
in vec4 vertexColor;
#endif

#ifndef EMISSIVE
in vec4 lightMapColor;
#endif

#ifndef NO_OVERLAY
in vec4 overlayColor;
#endif

in vec2 texCoord0;

#if defined(PLAYER_DOLL) || defined(PLAYER_DOLL_GUI)

bool dollSlimSkin() {
    vec4 a = texelFetch(Sampler0, ivec2(54, 20), 0);
    vec4 b = texelFetch(Sampler0, ivec2(55, 20), 0);
    return a.a < 0.5 || (a.rgb == vec3(0.0) && b.rgb == vec3(0.0));
}
#endif

#ifdef PLAYER_DOLL
flat in int dollPart;

const vec2 DOLL_INNER[5] = vec2[](vec2(16.0, 16.0), vec2(40.0, 16.0), vec2(32.0, 48.0), vec2(0.0, 16.0), vec2(16.0, 48.0));
const vec2 DOLL_OUTER[5] = vec2[](vec2(16.0, 32.0), vec2(40.0, 32.0), vec2(48.0, 48.0), vec2(0.0, 32.0), vec2(0.0, 48.0));
const vec3 DOLL_SIZE[5] = vec3[](vec3(8.0, 12.0, 4.0), vec3(4.0, 12.0, 4.0), vec3(4.0, 12.0, 4.0), vec3(4.0, 12.0, 4.0), vec3(4.0, 12.0, 4.0));

vec4 dollFaceRect(int face, vec2 o, vec3 s) {
    float w = s.x;
    float h = s.y;
    float d = s.z;
    if (face == 0) return vec4(o.x + d,             o.y,     o.x + d + w,             o.y + d);
    if (face == 1) return vec4(o.x + d + w,         o.y + d, o.x + d + w + w,         o.y);
    if (face == 2) return vec4(o.x,                 o.y + d, o.x + d,                 o.y + d + h);
    if (face == 3) return vec4(o.x + d,             o.y + d, o.x + d + w,             o.y + d + h);
    if (face == 4) return vec4(o.x + d + w,         o.y + d, o.x + d + w + d,         o.y + d + h);
    return             vec4(o.x + d + w + d,     o.y + d, o.x + d + w + d + w,     o.y + d + h);
}

vec2 dollRemap(vec2 uv, int part, bool slim) {
    vec2 px = uv * 64.0;
    ivec2 cell = ivec2(floor(px / 8.0));
    bool outer = cell.x >= 4;
    int column = cell.x - (outer ? 4 : 0);
    int face = cell.y == 0 ? (column == 1 ? 0 : 1) : column + 2;
    vec2 local = px / 8.0 - vec2(cell);
    if (face == 1) {
        local.y = 1.0 - local.y;
    }

    int i = part - 1;
    vec3 size = DOLL_SIZE[i];
    if (slim && (part == 2 || part == 3)) {
        size.x = 3.0;
    }
    vec4 r = dollFaceRect(face, outer ? DOLL_OUTER[i] : DOLL_INNER[i], size);

    vec2 target = mix(r.xy, r.zw, local);
    vec2 lo = min(r.xy, r.zw) + 0.001;
    vec2 hi = max(r.xy, r.zw) - 0.001;
    return clamp(target, lo, hi) / 64.0;
}
#endif

#ifdef PLAYER_DOLL_GUI
flat in int dollGui;
in vec2 dollGuiSt;
in vec2 dollGuiPos;

const float DOLL_GUI_YAW    = radians(-35.0);
const float DOLL_GUI_PITCH  = radians(-18.0);
const float DOLL_GUI_HALF   = 9.0;
const vec3  DOLL_GUI_CENTER = vec3(0.0, 7.0, 0.0);
const vec3  DOLL_GUI_LIGHT  = vec3(-0.35, 0.8, 0.5);

const vec3 BOX_CENTER[6] = vec3[](vec3(0.0078, 10.0000, -1.3950), vec3(0.0078, 3.5000, -1.3024), vec3(-3.8375, 3.5184, -1.3525),
                                  vec3(3.8375, 3.5178, -1.3525), vec3(-2.5756, 1.2499, 2.3760), vec3(2.5124, 1.2499, 2.2387));
const vec3 BOX_HALF[6] = vec3[](vec3(4.0, 4.0, 4.0), vec3(3.0, 3.5, 1.75), vec3(1.0, 3.0, 1.25),
                                vec3(1.0, 3.0, 1.25), vec3(1.25, 2.75, 1.25), vec3(1.25, 2.75, 1.25));
const mat3 BOX_ROT[6] = mat3[](
    mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0),
    mat3(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0),
    mat3(0.923880, -0.382683, 0.0, 0.382683, 0.923880, 0.0, 0.0, 0.0, 1.0),
    mat3(0.923880, 0.382683, 0.0, -0.382683, 0.923880, 0.0, 0.0, 0.0, 1.0),
    mat3(0.923880, 0.0, 0.382683, 0.382683, 0.0, -0.923880, 0.0, 1.0, 0.0),
    mat3(0.923880, 0.0, -0.382683, -0.382683, 0.0, -0.923880, 0.0, 1.0, 0.0));
const vec2 BOX_INNER_UV[6] = vec2[](vec2(0.0, 0.0), vec2(16.0, 16.0), vec2(40.0, 16.0),
                                    vec2(32.0, 48.0), vec2(0.0, 16.0), vec2(16.0, 48.0));
const vec2 BOX_OUTER_UV[6] = vec2[](vec2(32.0, 0.0), vec2(16.0, 32.0), vec2(40.0, 32.0),
                                    vec2(48.0, 48.0), vec2(0.0, 32.0), vec2(0.0, 48.0));
const vec3 BOX_UV_SIZE[6] = vec3[](vec3(8.0, 8.0, 8.0), vec3(8.0, 12.0, 4.0), vec3(4.0, 12.0, 4.0),
                                   vec3(4.0, 12.0, 4.0), vec3(4.0, 12.0, 4.0), vec3(4.0, 12.0, 4.0));

vec2 dollBoxTexel(vec3 p, vec3 n, vec2 o, vec3 s) {
    float w = s.x;
    float h = s.y;
    float d = s.z;
    float down = 1.0 - p.y;
    if (n.z > 0.5)  return vec2(o.x + d + p.x * w,                 o.y + d + down * h);
    if (n.z < -0.5) return vec2(o.x + d + w + d + (1.0 - p.x) * w, o.y + d + down * h);
    if (n.x > 0.5)  return vec2(o.x + d + w + (1.0 - p.z) * d,     o.y + d + down * h);
    if (n.x < -0.5) return vec2(o.x + p.z * d,                     o.y + d + down * h);
    if (n.y > 0.5)  return vec2(o.x + d + p.x * w,                 o.y + p.z * d);
    return              vec2(o.x + d + w + p.x * w,             o.y + p.z * d);
}

struct DollHit {
    float t;
    vec3 normal;
    vec4 color;
};

void dollBox(inout DollHit hit, vec3 ro, vec3 rd, vec3 center, vec3 extent, vec2 uvOrigin, vec3 uvSize, bool slimArm) {
    vec3 inv = 1.0 / rd;
    vec3 t0 = (center - extent - ro) * inv;
    vec3 t1 = (center + extent - ro) * inv;
    vec3 tmin = min(t0, t1);
    vec3 tmax = max(t0, t1);
    float tNear = max(max(tmin.x, tmin.y), tmin.z);
    float tFar = min(min(tmax.x, tmax.y), tmax.z);
    if (tNear > tFar || tFar < 0.0 || tNear >= hit.t) return;

    for (int side = 0; side < 2; side++) {
        float t = side == 0 ? tNear : tFar;
        if (t < 0.0 || t >= hit.t) continue;
        vec3 n;
        if (side == 0) {
            n = tNear == tmin.x ? vec3(-sign(rd.x), 0.0, 0.0) : (tNear == tmin.y ? vec3(0.0, -sign(rd.y), 0.0) : vec3(0.0, 0.0, -sign(rd.z)));
        } else {
            n = tFar == tmax.x ? vec3(sign(rd.x), 0.0, 0.0) : (tFar == tmax.y ? vec3(0.0, sign(rd.y), 0.0) : vec3(0.0, 0.0, sign(rd.z)));
        }
        vec3 p = clamp((ro + rd * t - (center - extent)) / (2.0 * extent), 0.0, 0.9999);
        vec3 s = uvSize;
        if (slimArm) {
            s.x = 3.0;
        }
        vec4 c = texelFetch(Sampler0, ivec2(floor(dollBoxTexel(p, n, uvOrigin, s))), 0);
        if (c.a >= 0.1) {
            hit.t = t;
            hit.normal = side == 0 ? n : -n;
            hit.color = c;
            return;
        }
    }
}

DollHit dollTrace(vec3 ro, vec3 rd) {
    bool slim = dollSlimSkin();
    DollHit hit = DollHit(1e9, vec3(0.0), vec4(0.0));

    for (int i = 0; i < 6; i++) {
        mat3 toLocal = transpose(BOX_ROT[i]);
        vec3 lro = toLocal * (ro - BOX_CENTER[i]);
        vec3 lrd = toLocal * rd;

        bool arm = (i == 2 || i == 3) && slim;
        float before = hit.t;
        dollBox(hit, lro, lrd, vec3(0.0), BOX_HALF[i], BOX_INNER_UV[i], BOX_UV_SIZE[i], arm);
        dollBox(hit, lro, lrd, vec3(0.0), BOX_HALF[i] + 0.25, BOX_OUTER_UV[i], BOX_UV_SIZE[i], arm);
        if (hit.t < before) {
            hit.normal = BOX_ROT[i] * hit.normal;
        }
    }
    return hit;
}

vec4 dollRender(vec2 st) {
    float cy = cos(DOLL_GUI_YAW);
    float sy = sin(DOLL_GUI_YAW);
    float cp = cos(DOLL_GUI_PITCH);
    float sp = sin(DOLL_GUI_PITCH);

    vec3 forward = vec3(-sy * cp, sp, -cy * cp);
    vec3 right = normalize(cross(forward, vec3(0.0, 1.0, 0.0)));
    vec3 up = cross(right, forward);

    vec2 ndc = vec2(st.x * 2.0 - 1.0, 1.0 - st.y * 2.0);
    vec3 ro = DOLL_GUI_CENTER - forward * 64.0 + (right * ndc.x + up * ndc.y) * DOLL_GUI_HALF;

    DollHit hit = dollTrace(ro, forward);
    if (hit.t >= 1e9) {
        return vec4(0.0);
    }

    float diffuse = max(dot(hit.normal, normalize(DOLL_GUI_LIGHT)), 0.0);
    float light = 0.55 + 0.45 * diffuse;
    return vec4(hit.color.rgb * light, 1.0);
}
#endif

#ifdef PLAYER_DOLL_ITEM
in vec3 dollItemPos;
in vec3 dollItemNormal;
in vec4 dollItemColor;
flat in float dollItemPerspective;
flat in vec3 dollItemCam;
#ifdef PLAYER_DOLL_LIT
flat in vec3 dollItemLight0;
flat in vec3 dollItemLight1;
#endif

const vec3 DOLL_ITEM_SCALE = vec3(1.6, 2.1, 1.45);
const vec3 DOLL_ITEM_CENTER = vec3(0.0, 7.0, 0.04);
const vec3 DOLL_ITEM_AXIS = vec3(1.0, -1.0, -1.0);
const float DOLL_ITEM_TOLERANCE = 0.03;

const int   FACE_UA[6] = int[](0, 0, 2, 0, 2, 0);
const float FACE_US[6] = float[](1.0, 1.0, -1.0, 1.0, 1.0, -1.0);
const int   FACE_VA[6] = int[](2, 2, 1, 1, 1, 1);
const float FACE_VS[6] = float[](-1.0, -1.0, 1.0, 1.0, 1.0, 1.0);
const int   FACE_NA[6] = int[](1, 1, 0, 2, 0, 2);
const float FACE_NS[6] = float[](-1.0, 1.0, -1.0, -1.0, 1.0, 1.0);

vec3 dollAxis(int i) {
    return i == 0 ? vec3(1.0, 0.0, 0.0) : (i == 1 ? vec3(0.0, 1.0, 0.0) : vec3(0.0, 0.0, 1.0));
}


int dollItem(out vec4 texel, out vec4 shade, vec3 dPX, vec3 dPY, vec2 dUX, vec2 dUY) {
    texel = vec4(0.0);
    shade = vec4(0.0);
    vec2 px = texCoord0 * 64.0;
    ivec2 cell = ivec2(floor(px / 8.0));
    if (cell.x < 0 || cell.x > 7 || cell.y < 0 || cell.y > 1) return 0;
    bool outer = cell.x >= 4;
    int column = cell.x - (outer ? 4 : 0);
    int face;
    if (cell.y == 0) {
        if (column != 1 && column != 2) return 0;
        face = column - 1;
    } else {
        face = column + 2;
    }
    int ua = FACE_UA[face];
    int va = FACE_VA[face];
    int na = FACE_NA[face];

    float ax = 64.0 * FACE_US[face] * dUX.x;
    float ay = 64.0 * FACE_US[face] * dUY.x;
    float bx = 64.0 * FACE_VS[face] * dUX.y;
    float by = 64.0 * FACE_VS[face] * dUY.y;
    float det = ax * by - ay * bx;
    if (!(abs(det) > 1e-3 * (abs(ax * by) + abs(ay * bx)))) return 0;

    vec3 mU = (dPX * by - dPY * bx) / det;
    vec3 mV = (dPY * ax - dPX * ay) / det;
    float lu = length(mU) / dot(DOLL_ITEM_SCALE, dollAxis(ua));
    float lv = length(mV) / dot(DOLL_ITEM_SCALE, dollAxis(va));
    if (!(lu > 0.0 && lv > 0.0) || abs(log(lu / lv)) > DOLL_ITEM_TOLERANCE) return 0;
    if (outer) return 2;

    vec3 n = normalize(cross(mU, mV));
    if (dot(n, dollItemNormal) < 0.0) n = -n;
    vec3 mN = FACE_NS[face] * n * (0.5 * (lu + lv)) * dot(DOLL_ITEM_SCALE, dollAxis(na));
    mat3 m = outerProduct(mU, dollAxis(ua)) + outerProduct(mV, dollAxis(va)) + outerProduct(mN, dollAxis(na));
    mat3 mi = inverse(m);

    vec2 local = px / 8.0 - vec2(cell);
    vec3 c = dollAxis(ua) * (FACE_US[face] * (2.0 * local.x - 1.0) * 4.0)
           + dollAxis(va) * (FACE_VS[face] * (2.0 * local.y - 1.0) * 4.0)
           + dollAxis(na) * (FACE_NS[face] * 4.0);

    vec3 d = dollItemPerspective > 0.5 ? mi * (dollItemPos - dollItemCam) : mi * dollItemCam;
    vec3 scale = DOLL_ITEM_AXIS * DOLL_ITEM_SCALE;
    vec3 rd = scale * d;
    vec3 ro = dollItemPerspective > 0.5 ? scale * (c - d) + DOLL_ITEM_CENTER
                                         : scale * c + DOLL_ITEM_CENTER - rd * (64.0 / length(rd));
    DollHit hit = dollTrace(ro, rd);
    if (hit.t >= 1e9) return 2;

    vec3 normal = normalize(transpose(mi) * (scale * hit.normal));
    shade = dollItemColor;
#ifdef PLAYER_DOLL_LIT
    vec2 light = max(vec2(dot(dollItemLight0, normal), dot(dollItemLight1, normal)), vec2(0.0));
    shade.rgb *= min(1.0, (light.x + light.y) * 1.0 + 0.4);
#endif
    texel = vec4(hit.color.rgb, 1.0);
    return 1;
}
#endif

out vec4 fragColor;

void main() {
#ifdef PLAYER_DOLL_GUI
    if (dollGui == 1) {
        vec2 st = dollGuiSt;
        vec2 dPos = vec2(dFdx(dollGuiPos.x), dFdy(dollGuiPos.y));
        vec2 dSt = vec2(dFdx(dollGuiSt.x), dFdy(dollGuiSt.y));
        if (dPos.x * dSt.x < 0.0) {
            st.x = 1.0 - st.x;
        }
        if (dPos.y * dSt.y < 0.0) {
            st.y = 1.0 - st.y;
        }
        vec4 doll = dollRender(st);
        if (doll.a < 0.5) {
            discard;
        }
        fragColor = doll * ColorModulator;
        return;
    }
#endif

    vec2 uv = texCoord0;
#ifdef PLAYER_DOLL
    if (dollPart > 0) {
        uv = dollRemap(texCoord0, dollPart, (dollPart == 2 || dollPart == 3) && dollSlimSkin());
    }
#endif
    vec4 color = texture(Sampler0, uv);

#ifdef PLAYER_DOLL_ITEM
    int itemDoll = 0;
    vec4 itemShade = vec4(0.0);
    {
        vec3 dPX = dFdx(dollItemPos);
        vec3 dPY = dFdy(dollItemPos);
        vec2 dUX = dFdx(texCoord0);
        vec2 dUY = dFdy(texCoord0);
        bool candidate = textureSize(Sampler0, 0) == ivec2(64, 64);
#ifdef PLAYER_DOLL
        candidate = candidate && dollPart == 0;
#endif
        vec4 itemTexel = vec4(0.0);
        if (candidate) {
            itemDoll = dollItem(itemTexel, itemShade, dPX, dPY, dUX, dUY);
        }
        if (itemDoll == 2) {
            discard;
        }
        if (itemDoll == 1) {
            color = itemTexel;
        }
    }
#endif
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif

#ifdef PER_FACE_LIGHTING
    vec4 faceVertexColor = gl_FrontFacing ? vertexPerFaceColorFront : vertexPerFaceColorBack;
#else
    vec4 faceVertexColor = vertexColor;
#endif
#ifdef PLAYER_DOLL_ITEM
    if (itemDoll == 1) {
        faceVertexColor = itemShade;
    }
#endif

#ifdef DISSOLVE
    if (faceVertexColor.a < texture(DissolveMaskSampler, texCoord0).a) {
        discard;
    }
    faceVertexColor.a = 1.0;
#endif

    color *= faceVertexColor * ColorModulator;
#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
    color *= lightMapColor;
#endif

    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
