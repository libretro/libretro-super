# License: MIT
# Copyright (C) Google
# Author: Vladimit 'phcoder' Serbinenko

import os
import csv

MISSING = 'missing'
OK = 'OK'
DISABLED = 'disabled'
ENABLED = 'enabled'

coremap = {}
allcores = set()
allplatformset = set()
corestatus = {}
corereason = {}

GFX_FEATS = ['gfxaccel', 'gl1', 'gl2', 'gl3', 'gles2', 'gles3']
CPU_FEATS = ['x86_any', 'libco', 'cpu64', 'threads', 'jit']
PERIPHERAL_FEATS = ['cdrom', 'usb']
ALL_FEATS = GFX_FEATS + CPU_FEATS + PERIPHERAL_FEATS
DESKTOP_ALL = list(set(ALL_FEATS) - set(['gles2', 'gles3', 'cpu64', 'x86_any']))
DESKTOP_X64 = DESKTOP_ALL + ['x86_any', 'cpu64']
DESKTOP_X86 = DESKTOP_ALL + ['x86_any']
DESKTOP_ARM32 = DESKTOP_ALL
UWP = ['gfxaccel', 'gles2', 'threads', 'libco'] + ['cdrom', 'usb'] # unsure about second part
MOBILE = ['gfxaccel', 'gles2', 'gles3', 'threads', 'libco']
features_platforms = {
    # Misc
    'emscripten': ['gfxaccel', 'gles2'],

    # consoles
    '3ds': ['threads', 'libco', 'jit'],
    'psl1ght': ['cpu64'] + ['libco', 'cdrom', 'usb', 'jit'], # unsure about second part
    'gamecube': ['threads', 'libco'] + ['cdrom', 'jit'], # unsure about second part
    'wii': ['threads', 'libco'] + ['cdrom', 'usb', 'jit'], # unsure about second part
    'ps2': [] + ['libco', 'cpu64', 'threads', 'cdrom', 'usb', 'jit'],  # unsure about second part
    'ps3': ['threads', 'cpu64'] + ['libco', 'cdrom', 'usb', 'jit'],  # unsure about second part
    'psp': ['libco', 'threads'] + ['jit'],  # unsure about second part
    'libnx': ['gfxaccel', 'gl1', 'gl2', 'gl3', 'libco', 'cpu64', 'threads', 'jit'] + ['usb'],  # unsure about second part
    'wiiu': ['libco'] + ['cdrom', 'usb', 'jit'],  # unsure about second part
    'vita': ['gfxaccel', 'gl1', 'gl2', 'threads', 'libco', 'jit'], # 'gl3', 'gles2', 'gles3'?

    # UWP
    'windows-uwp-arm': UWP,
    'windows-uwp-x64': UWP + ['x86_any', 'cpu64'],
    'windows-uwp-x86': UWP + ['x86_any'],

    # Mobile
    'android' : MOBILE + ['x86_any', 'cpu64', 'jit'],
    'ios': MOBILE,
    'ios9': MOBILE,
    'ios-arm64': MOBILE + ['cpu64'],
    'tvos-arm64': MOBILE + ['cpu64'],
    'qnx': MOBILE, # Unsure about usb

    # Desktop
    'linux-x64': DESKTOP_X64,
    'windows-x64': DESKTOP_X64,
    'osx-x64': DESKTOP_X64,
    'linux-x86': DESKTOP_X86,
    'windows-x86': DESKTOP_X86,
    'linux-arm7neonhf': DESKTOP_ARM32,
    'linux-armhf': DESKTOP_ARM32,
    'xbox-x86': DESKTOP_X86,
}
features_cores = {
    '3dengine': ['gl2'], # Should be gl2 or gles2 but current bugs prevent operating with gles2
    'atari800': ['libco'],
    'blastem': ['x86_any'],
    'boom3': ['gl1'],
    'boom3_xp': ['gl1'],
    'bsnes': ['libco'],
    'bsnes2014': ['libco'],
    'bsnes_cplusplus98': ['libco'],
    'bsnes_hd_beta': ['libco'],
    'bsnes_mercury': ['libco'],
    'citra': ['gfxaccel'],
    'citra_canary': ['gfxaccel'],
    'craft': ['gfxaccel'],
    'dolphin': ['cpu64', 'jit'],
    'dosbox_svn': ['libco'],
    'dosbox_svn_ce': ['libco'],
    'dosbox_core': ['threads'],
    'ffmpeg': ['threads'],
    'flycast': ['gfxaccel'],
    'frodo': ['libco'],
    'hatari': ['libco'],
    'gpsp': ['libco'],
    'ishiiruka': ['cpu64'],
    'kronos': ['gl3'],
    'mednafen_psx_hw': ['gfxaccel'],
    'mupen64plus_next': ['gfxaccel', 'libco'],
    'mupen64plus_next_gles2': ['gles2', 'libco'],
    'mupen64plus_next_gles3': ['gles3', 'libco'],
    'openlara': ['gfxaccel'],
    'parallel_n64': ['gfxaccel', 'libco'],
    'play': ['gfxaccel'],
    'redbook': ['cdrom'],
    'remotejoy': ['usb'],
    'reminiscence': ['libco'],
    'scummvm': ['libco'],
    'thepowdertoy': ['threads'],
    'vitaquake3': ['gl1'],
    'vitavoyager': ['gl1'],
    'yabasanshiro': ['gfxaccel']
}

def strip_suffix(s, suffix):
    if s.endswith(suffix):
        return s[:-len(suffix)]
    return s

def strip_suffixes(s, suffixes):
    r = s
    for suffix in suffixes:
        r = strip_suffix(r, suffix)
    return r


def strip_prefix(s, prefix):
    if s.startswith(prefix):
        return s[len(prefix):]
    return s

def strip_prefixes(s, prefixes):
    r = s
    for prefix in prefixes:
        r = strip_prefix(r, prefix)
    return r


def file_to_platform(fname):
    s = strip_suffixes(fname, ["-generic", "-noccache", "-r16b", "-cross", "_dw2", "_seh", "_sjlj", "_w32"])
    s = strip_prefixes(s, ["cores-"])
    for infix in ["msvc2003", "msvc2005", "msvc2010", "msvc2017", "desktop"]:
        s = s.replace("-" + infix + "-", "-")
    return s

for root, _, files in os.walk("recipes"):
    for file in files:
        if file.endswith(".conf") or file.endswith(".ra") or file.endswith(".yml") or file.endswith(".info") or file.endswith(".sh") or file.startswith("retroarch-"):
            continue

        if file in ["cores-android-aarch64", "cores-android-armv7-ndk-mame"]:
            continue

        platform = file_to_platform(file)
        allplatformset.add(platform)

        with open(os.path.join(root, file)) as fin:
            for line in fin:
                sp = line.split()
                if len(sp) == 0:
                    continue
                core = sp[0]
                k = (platform, core)
                if k not in coremap:
                    coremap[k] = []
                coremap[k].append({'file': file, ENABLED: sp[4]})
                allcores.add(core)

allplatforms = sorted(allplatformset)
cf = open ("comptable.csv", "w")
c = csv.writer(cf)

c.writerow([""] + allplatforms)

for core in allcores:
    row = [core]
    for platform in allplatforms:
        k = (platform, core)
        if k not in coremap: 
            status = MISSING
        else:
            enabled = False
            for x in coremap[k]:
                if x[ENABLED] == 'YES':
                    enabled = True
            if enabled:
                status = OK
            else:
                status = DISABLED
        corestatus[k] = status
        if core in features_cores and platform in features_platforms:
            missing = set(features_cores[core]) - set(features_platforms[platform])
            if missing:
                corereason[k] = ','.join(missing)
        
            
                
for core in sorted (allcores):
    row = [core]
    for platform in allplatforms:
        k = (platform, core)
        st = corestatus[k]
        s = st
        if st != OK and k in corereason:
            s += " (" + corereason[k] + ")"
        if st == OK and k in corereason:
            print("%s is enabled on %s despite %s" % (core, platform, corereason[k]))
        row += [s]
    c.writerow(row)

cf.close()
