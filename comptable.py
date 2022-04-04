#!/usr/bin/env python3

# License: MIT
# Copyright (C) Google
# Author: Vladimit 'phcoder' Serbinenko

import os
import csv
import requests

hostname = 'git.libretro.com'
namespace = 'libretro'

MISSING = 'missing'
OK = 'OK'
BROKEN = 'broken'

coremap = {}
allcores = set()
allplatformset = set()
corestatus = {}
corereason = {}

SUBCORE_SUFFIXES = [
    "plus",

    # bsnes
    "accuracy", "balanced", 

    # Beetle PSX
    "hw",
    
    # Quake
    "rogue", "xatrix", "zaero",

    # VICE
    "xpet", "xplus4", "xscpu64", "xvic", "x128", "x64sc", "xcbm2", "xcbm5x0",

    # Boom3
    "xp",

    # MAME
    "cdi2015"
]
GFX_FEATS = ['gfxaccel', 'gl1', 'gl2', 'gl3', 'gles2', 'gles3']
CPU_FEATS = ['x86_any', 'libco', 'cpu64', 'threads', 'thread-local', 'jit', 'little_endian']
PERIPHERAL_FEATS = ['cdrom', 'usb']
LANG_FEATS = ['c++14', 'c++11']
MISC_FEATS = ['physfs', 'jvm']
ALL_FEATS = GFX_FEATS + CPU_FEATS + PERIPHERAL_FEATS + MISC_FEATS + LANG_FEATS
DESKTOP_COMMON = list(set(ALL_FEATS) - set(['gles2', 'gles3', 'cpu64', 'x86_any', 'little_endian']))
DESKTOP_X64 = DESKTOP_COMMON + ['x86_any', 'cpu64', 'little_endian']
DESKTOP_X86 = DESKTOP_COMMON + ['x86_any', 'little_endian']
DESKTOP_X64_NO_CXX11 = list(set(DESKTOP_X64) - set(['c++14', 'c++11']))
DESKTOP_X86_NO_CXX11 = list(set(DESKTOP_X86) - set(['c++14', 'c++11']))
DESKTOP_ARM32LE = DESKTOP_COMMON + ['little_endian']
DESKTOP_PPC = DESKTOP_COMMON
UWP = ['gfxaccel', 'gles2', 'threads', 'thread-local', 'libco'] + ['cdrom', 'usb', 'physfs', 'c++14', 'c++11', 'jvm'] # unsure about second part
MOBILE_LE = ['gfxaccel', 'gles2', 'gles3', 'threads', 'libco', 'little_endian']
ANDROID = MOBILE_LE + ['jit', 'physfs', 'thread-local', 'c++14', 'c++11', 'jvm']
features_platforms = {
    # Misc
    'emscripten': ['gfxaccel', 'gles2', 'little_endian', 'physfs', 'c++14', 'c++11'],

    # consoles
    'ctr': ['threads', 'thread-local', 'libco', 'jit', 'little_endian', 'c++14', 'c++11'],
    'psl1ght': ['cpu64'] + ['libco', 'cdrom', 'usb', 'jit', 'c++14', 'c++11'], # unsure about second part
    'ngc': ['threads', 'thread-local', 'libco'] + ['cdrom', 'jit', 'c++14', 'c++11'], # unsure about second part
    'wii': ['threads', 'thread-local', 'libco'] + ['cdrom', 'usb', 'jit', 'c++14', 'c++11'], # unsure about second part
    'ps2': ['little_endian'] + ['libco', 'cpu64', 'threads', 'thread-local', 'cdrom', 'usb', 'jit', 'c++14', 'c++11'],  # unsure about second part
    'ps3': ['threads', 'thread-local', 'cpu64'] + ['libco', 'cdrom', 'usb', 'jit', 'c++14', 'c++11'],  # unsure about second part
    'psp': ['libco', 'threads', 'thread-local', 'little_endian'] + ['jit', 'c++14', 'c++11'],  # unsure about second part
    'libnx-aarch64': ['gfxaccel', 'gl1', 'gl2', 'gl3', 'libco', 'cpu64', 'threads', 'thread-local', 'jit', 'little_endian'] + ['usb', 'c++14', 'c++11'],  # unsure about second part
    'wiiu': ['libco'] + ['cdrom', 'usb', 'jit', 'c++14', 'c++11'] + ['threads'],  # unsure about second part. Threads are present in OS but not in rthreads yet
    'vita': ['gfxaccel', 'gl1', 'gl2', 'threads', 'thread-local', 'libco', 'jit', 'little_endian', 'c++14', 'c++11'], # 'gl3', 'gles2', 'gles3'?

    # UWP
    'windows-uwp-arm': UWP + ['little_endian'],
    'windows-uwp-x64': UWP + ['x86_any', 'cpu64', 'little_endian'],
    'windows-uwp-x86': UWP + ['x86_any', 'little_endian'],

    # Mobile
    'android-arm64-v8a': ANDROID + ['cpu64'],
    'android-armeabi-v7a': ANDROID,
    'android-x86': ANDROID + ['x86_any'],
    'android-x86_64': ANDROID + ['x86_any', 'cpu64'],
    'ios': MOBILE_LE + ['physfs', 'c++14', 'c++11'],
    'ios9': MOBILE_LE + ['physfs', 'c++14', 'c++11'],
    'ios-arm64': MOBILE_LE + ['cpu64', 'physfs', 'thread-local', 'c++14', 'c++11'],
    'tvos-arm64': MOBILE_LE + ['cpu64', 'physfs', 'thread-local', 'c++14', 'c++11'],
    'qnx': MOBILE_LE + ['physfs', 'thread-local', 'c++14', 'c++11', 'jvm'], # Unsure about usb and thread-local

    # Desktop
    'linux-x64': DESKTOP_X64,
    'windows-x64': DESKTOP_X64,
    'osx-x64': DESKTOP_X64,
    'linux-i686': DESKTOP_X86,
    'windows-i686': DESKTOP_X86,
    'linux-arm7neonhf': DESKTOP_ARM32LE,
    'linux-armhf': DESKTOP_ARM32LE,
    'xbox-x86': DESKTOP_X86,
    'windows-msvc05-i686': DESKTOP_X86_NO_CXX11,
    'windows-msvc10-i686': DESKTOP_X86_NO_CXX11,
    'windows-msvc10-x64': DESKTOP_X64_NO_CXX11,
    'osx-ppc': [x for x in DESKTOP_PPC if x != 'c++14' and x != 'c++11']
}
features_cores = {
    '3dengine': ['gl2'], # Should be gl2 or gles2 but current bugs prevent operating with gles2
    'atari800': ['libco'],
    'blastem': ['x86_any'],
    'boom3': ['gl1'],
    'boom3-xp': ['gl1'],
    'bsnes': ['libco'],
    'bsnes2014': ['libco'],
    'bsnes-libretro-cplusplus98': ['libco'],
    'bsnes-hd': ['libco'],
    'bsnes-mercury': ['libco'],
    'chailove': ['physfs', 'thread-local', 'threads'],
    'citra': ['gfxaccel'],
    'citra2018': ['gfxaccel'],
    'Craft': ['gfxaccel'],
    'chailove': ['c++14'],
    'dolphin': ['cpu64', 'jit'],
    'dosbox-svn': ['libco'],
    'dosbox-core': ['threads'],
    'dosbox-pure': ['c++11', 'threads'],
    'ffmpeg': ['threads'],
    'flycast': ['gfxaccel'],
    'flycast-upstream': ['gfxaccel'],
    'frodo': ['libco'],
    'hatari': ['libco'],
    'gpsp': ['libco'],
    'ishiiruka': ['cpu64'],
    'kronos': ['gl3'],
    'mupen64plus': ['gfxaccel', 'libco'],
    'neocd': ['c++11'],
    'Omicron': ['gfxaccel', 'jvm'],
    'OpenLara': ['gfxaccel'],
    'parallel-n64': ['gfxaccel', 'libco'],
    'pcem': ['threads'],
    'play': ['gfxaccel'],
    'redbook': ['cdrom'],
    'remotejoy': ['usb'],
    'retro8': ['c++11'],
    'REminiscence': ['libco'],
    'scummvm': ['libco'],
    'ThePowderToy': ['threads'],
    'tic80': ['little_endian'],
    'uae': ['threads'],
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
    for suffix in suffixes + suffixes + suffixes:
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
    s = strip_suffixes(fname, [
        "-legacy", "-mingw",

        # Mupen64
        "-gles2", "-gles3",
    ] + ["-" + x for x in SUBCORE_SUFFIXES])
    s = strip_prefixes(s, ["libretro-", "build-", "static-",
                           "retroarch-", "dummy-", "deps:", "test:"])
#    for infix in ["msvc05", "msvc10"]:
#        s = s.replace("-" + infix + "-", "-")
    mp = {
        'code_quality': None,
        'ios-9': 'ios9',
        'trigger_static-cores': None,
        "android": None,
        'osx': None,
        'switch': None
    }
    if s in mp:
        s = mp[s]
    subcore = list(filter(lambda x: "-" + x + "-" in fname
                          or fname.endswith("-" + x), SUBCORE_SUFFIXES))
    return (s, "-".join(subcore))

def repo_to_core(repname):
    s = strip_suffixes(repname, ["-nx", "-libretro", "_libretro"])
    s = strip_prefixes(s, ["libretro-"])
    return s

def page_get(base):
    per_page = 20
    res = []
    for page in range(1, 30):
        add = requests.get(base + ('per_page=%d&page=%d' % (per_page, page))).json()
        res += add
        if len(add) != per_page:
            return res
    return res

def parse_pipelines(projectid, sha):
    pipelines = requests.get('https://%s/api/v4/projects/%d/pipelines?sha=%s&per_page=20' % (hostname, projectid, sha)).json()
    for pipeline in pipelines:
        if pipeline['status'] == 'success':
#            print(pipeline)
            return page_get('https://%s/api/v4/projects/%d/pipelines/%d/jobs?' % (hostname, projectid, pipeline['id']))
    return None

projects_all = page_get('https://%s/api/v4/projects?simple=true&' % hostname)

projects = list(filter(lambda x: x['namespace']['path'] == namespace, projects_all))

for project in projects:
    print(project['path_with_namespace'])
    projectid = project['id']
    core_base = repo_to_core(project['path'])
    if core_base == 'RetroArch':
        continue
    commits = requests.get('https://%s/api/v4/projects/%d/repository/commits?ref_name=%s' % (hostname, projectid, project['default_branch'])).json()
#    print(commits[0])
    jobs = None
    for commit in commits:
        jobs = parse_pipelines(projectid, commit['id'])
        if jobs is not None:
            break
    if jobs is None:
        jobs = []
    if not jobs:
        allcores.add(core_base)
    for job in jobs:
#        print(job)
        (platform, subcore) = file_to_platform(job['name'])
        if platform is None:
            continue
        if subcore:
            core = core_base + "-" + subcore
        else:
            core = core_base
        allplatformset.add(platform)
        allcores.add(core)
        k = (platform, core)
        if k not in coremap:
            coremap[k] = []
        coremap[k].append({'status': job['status']})


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
            status = OK if any(map(lambda x: x['status'], coremap[k])) else BROKEN
        corestatus[k] = status
        if core in features_cores and platform in features_platforms:
            missing = set(features_cores[core]) - set(features_platforms[platform])
            if missing:
                corereason[k] = ','.join(missing)
            
                
for core in sorted (allcores):
    if core in ('dosbox-libretro',):
        continue
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
