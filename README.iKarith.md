First, an introduction is in order:

Hi, I'm iKarith, and probably you don't know me.  :)  I'm not really part of
any "scene" or anything.  Long story short, I wanted to build a stand-alone
emulator-based box for my fiancée and thought RetroArch might give her
something clean, seamless, and foolproof once I set it up.  And as some of
you who haven't been big fans of RetroArch may guess, that wasn't easy.

Two choices existed: Complain, or fix it.  I chose to fix it.  And when I
found out where things were headed for RetroArch, I decided to first see about
improving its build process.

To that end, this file and the files in the repo with "iKarith" in the name
were created.  They're temporary and will go away once this project's done.
This file in particular explains what I'm doing and why.  So read on if that
stuff interests you.  :)

iKarith, 2015-02-07


# Some philosophy

Libretro should be an API, not a project.  You might want to argue with me as
to whether or not that's true.  And you might be surprised to find me agree
that as of today, it *is* a project and not an API.  But that model is IMO not
infinitely sustainable.  You can't just fork every open source game project
out there.

You can't even do that with all the emulators.  And even if you could, it'd be
a nightmare trying to compile them all, let alone maintain them.  And it's
just not realistic to hand a user a dozen SNES emulators with no explanation
of what's what and expect them to know what to do with them all, especially
since there are multiple versions of some of them.  Now multiply that by all
of the systems and all of the emulator engines and all of the versions of some
of them that exist.  It just does not scale.


## The technical problem

Leaving aside the philosophical direction of where libretro is headed for a
moment, its build scripts don't really function well for where the project is
at today, let alone in the future when it's "not really a project" anymore.

You see, libretro does not have one build script.  In fact, it doesn't even
have one build script per target platform.  No, there's the combination of
libretro-fetch.sh, libretro-build.sh, and retroarch-build.sh and their
included subscript dependencies.  In addition, there's about a dozen or so
platform-specific build scripts which have some overlap with the main scripts
and (inconsistently) use their dependent subscripts.  In addition, there's a
handful of XCode projects for Mac OS X which are intended to be backward
compatible with old versions of the OS but aren't.  And there's a whole
additional set of build scripts replacing most of these almost in their
entirety written for the buildbot.  And then there's the Makefiles which
are often just as much of a mess (but a separate problem…)

This is why the iKarith-\*.sh scripts.  If you touch any of the mainline
scripts to do what we need to do, you *will* break something.  In fact, I
happen to know that most of the scripts need a (fairly trivial) patch as it
is.  Mea culpa for introducing the need, but those scripts that don't get
patched before I get to them are the ones I can assume may have suffered other
forms of bit rot and will require additional care/testing.


## The Political Problem?

As I said, I don't really know anybody.  So I can't pretend to understand all
of the issues involved with devs in the various "scenes" in question.  I know
some people feel that they should retain control of their projects.  I have
seen someone accuse libretro of trying to "steal" other projects to improve
their own.  There are probably other issues, some of them personal, and I just
don't know them.  And I don't need to, honestly.

What I can say is that what I have in mind for the new build system makes
libretro-super function kind of like Debian/Ubuntu's package system.  You give
it the equivalent of an apt sources.list entry and it should be able to
download your project from your site, build it for your system, package it,
and possibly even give you the means to upload it to a repository.

My own future interests involve building a standalone libretro player for a
single project so that you can build something that targets the API and
distribute it as a stand-alone game, and a small version of SDL that's built
for libretro so that SDL-based games could be compiled for use on lakka.TV
down the line.  Remember what I said I originally wanted to accomplish?

I don't know if any of this stuff will help or hinder resolution of any
outstanding issues between anyone.  I'm just here to make cool stuff easy
enough for my fiancée to use it, remember?  :)


# The solution

To begin with, let's talk about the proof of concept I have already
implemented.  Then we'll discuss where it goes from here.  For this discussion
we will use the 2048 project because it's an incredibly simple example.  In
fact it's just about as close to a functional "hello world" for libretro as I
can imagine.  Currently it fetches and compiles using these rules:

```bash
fetch_libretro_2048() {
   fetch_git "$REPO_BASE/libretro/libretro-2048.git" "libretro-2048" "libretro/2048"
}

build_libretro_2048() {
   build_libretro_generic_makefile "2048" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}
```

What happens if we take the information contained there and turn it into a
bunch of shell variables that describe what to do with "2048":

```bash
core_2048_dir="libretro-2048"
core_2048_fetch=fetch_git
core_2048_source="$REPO_BASE/libretro/libretro-2048.git"
core_2048_build_rule=build_libretro_generic_makefile_s
core_2048_makefile="Makefile.libretro"
core_2048_other_args="$FORMAT_COMPILER_TARGET"
```

You'll notice that the build subdir is not specified—it's implicit.  You'd
only have to set the variable if you needed to specify one.  If the project
used ``makefile`` or ``Makefile`` to build for libretro, you wouldn't need to
specify that either.  And actually, so much of the above "core definition"
uses what would be reasonable defaults, you really only need to specify the
``core_2048_source`` and ``core_2048_makefile`` lines.  The rest could be
totally implicit, but I never really got that far before I had to attend to
other things.

But the info doesn't have to be specified in shell variable format.  In fact
it's not actually that difficult given bash to actually parse a file like
this:

```ini
[2048]
source = "https://github.com/libretro/libretro-2048.git"
makefile = "Makefile.libretro"
```

or even

```ini
display_name = "2048"
authors = "Gabriele Cirulli"
supported_extensions = ""
corename = "2048"
categories = "Game"
systemname = "2048 game clone"
license = "GPLv3"
permissions = ""
display_version = "1.0"
supports_no_game = "true"
source = "https://github.com/libretro/libretro-2048.git"
makefile = "Makefile.libretro"
```

Yes, the .info file could contain instructions for compiling.  Not useful to
RetroArch in the least, but useful if the .info file becomes the basis of a
package description.  Which is kind of what I have in mind.

## Still needed

The FORMAT_COMPILER_TARGET variable and FORMAT_COMPILER_TARGET_ALT are
extremely simple.  They are kind of used to specify which compiler toolchain
to use, but the settings are defined, redefined, or overridden in about four
or five different places including sometimes the cores' Makefile!  And on my
system, it is simply "osx".  I have two versions of gcc and a Clang available
here, and I can build code for any of 8 architectures, two of which my system
can also actually run.  And the only configuration of my compiler is "osx"?

Let's start by defining my system with a system and a native architecture.
We'll use MacOSX-x86_64.  And I have multiple compiler toolchains available.
Let's assume that libretro-super identifies Clang and the gcc version that
runs as ``/usr/bin/gcc``.  Both build for MacOSX-x86_64, so I would wind up
having two compiler profiles.

If a core can't build with Clang, its build recipes might specify a preference
for gcc if there are choices, or even indicate a conflict with Clang older
than whatever version is current if we ever get around to implementing that
kind of thing.  If it can't build with my system, it should be skipped by
default unless explicitly requested otherwise.

Those cores like 2048 that build as universal binaries might say that on
MacOSX-x86_64 and MacOSX-i386 it prefers MacOSX-Intel which would be a fat
binary for both.  Those kinds of overrides are why the existing info file may
NOT be suitable for specifying all the build rules, even if most of them are
implicit.


## External sources

This stuff is still a work in progress in my head (even more than compiler
profiles by target), but here we go.

Let's say the [SuperTux](http://supertux.lethargik.org/) project wants to
target libretro.  Awesome, right?  All they would have to do is publish a link
somewhere.  I'll make one up for the purpose of running:

```bash
./libretro-super.sh add-repo http://supertux.lethargik.org/libretro
```

Update the repo list to make sure I have the build rules and I should be able
to just do something like this:

```bash
./libretro-super.sh auto-package supertux/SuperTux
```

This would perform all steps to build a packaged version of SuperTux for my
system, which in this case requires a full fetch, build, and package.

The package likely named ``supertux_libretro_MacOSX-x86_64.zip`` would
contain:

```
supertux_libretro.dylib
supertux_libretro.info
COPYING_v3.txt
README-libretro.txt
```

The file README-libretro.txt would be a simple blurb that this version of the
game is built as a plugin for a libretro player and directs you to the
SuperTux website and to information about what a libretro player is and where
you'd find one.

You'll note I adopt the Windows and frankly everything but CLI UNIX convention
of adding an extension to COPYING.  I also chose to give it a version
designation.


# Porting features

Porting features from the iKarith scripts to the standard scripts is fine,
indeed it's welcome.  Just keep in mind that while it's possible to do, you
really need to test everything you can if you do.  At the very least, make
sure that you test Linux, Windows, and OS X if possible.  You might also want
to check with radius as to whether or not your changes will break his
buildbot.

That's about all I can think of for now.  This file will see updates as the
concepts contained herein evolve.


<!-- vi: set tw=78 ts=8 sw=8 noet ft=markdown: -->
