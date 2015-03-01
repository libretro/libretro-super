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

## History

2015-02-17.0: Updated to reflect the now deleted iKarith files
              There are changes to the planned implementation not discussed
	      here yet, so just know that that section is still obsolete.  It
	      is still in the RFC stage, though, so it can wait a day or two.
2015-02-08.1: Extensive rewrite of future direction portions
2015-02-08.0: Added discussion of dependencies
2015-02-07.1: Changed heading levels
2015-02-07.0: initial writing

## Some philosophy

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


### The technical problem

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

Originally I began working on this using iKarith-\*.sh scripts which were
copies of the build scripts in libretro-super, but were a safe sandbox for
changing stuff.  The reason was that if you touch the mainline scripts in any
significant way, you *will* break something.  Indeed, many of the more minor
platform build scripts will not function at present without a (fairly trivial)
patch to enable them to be used outside of the libretro-super directory.

I'm personally leaving them in their known slightly-broken state.  Justified
by the fact that any script that goes unpatched hasn't been tested in awhile
and needs more careful scrutiny when its features are incorporated into the
new build system.


### The Political Problem?

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


## Dependencies

For all the discussion of "no external dependencies", libretro and the stuff
ported to it have a lot of them.  That's unavoidable, actually.  To simplify
the argument, let's presume a GNU/Linux build environment.  You can't compile
anything without a compiler and binutils.  And the only way you're going to
compile large batches of code is a dependency on make.  Those are obvious.


### The less obvious dependencies

Continuing with our Linux example, all make does is give you a way to specify
what commands are required to create/update a file, and what files it is
created from.  From there, the commands are executed in a shell, which
introduces a dependency on the shell, but also the shell commands.  Things
like echo and cp are not traditionally "builtins", but rather external
programs that were traditionally smaller than the ELF header required to tell
Linux how to run them.  (And old enough versions of Linux didn't use ELF…)

By this point you've got literally 500MB of dependencies on a modern Linux
system.  You could argue that some of that is irrelevant because classically
all of the above fit into 50MB on a Linux system dating back to a 1.x kernel
and the fact that the dependencies have bloated so much (largely for UTF-8,
translation, internationalization, etc.) isn't our problem.  That's fair
enough, but we still have a minimum of 50MB of build dependencies on Linux.

Add the build scripts in there and you add dependencies on git (which means
also perl and possibly python though nothing we do requires anything that uses
python until you try to build mame at least) and explicitly on bash.  I'm
pretty sure our current build scripts will run on bash 2.05 at least, but most
folks assume bash 4 is available on all systems these days.  (It's not—the Mac
still comes with bash 3.)

If we remove the bash dependency, we could claim a POSIX environment as a
build dependency, but notably some platforms are not and do not even pretend
to be POSIX, such as that little insignificant OS called Windows.  You could
install MSYS (or more likely MSYS2) to try and fake it at the shell script
level, but MSYS2 is one *significant* dependency.

This is why autoconf exists.  It's also why autoconf is the gigantic mess
(both in terms of size and ugly complexity) that it is: It cannot assume a
fully POSIX system, and the POSIX standard is pretty dated anyway.  It has to
figure out all of the quirks of UNIX-style (and non-UNIX) systems running on 8
bit processors that haven't been updated in 35 years or more.


### So, what's your point?

The point is that we cannot say that we have no, or even few build
dependencies.  And at present, the ones we do have are not declared.  Fixing
this can be done in three ways, two of which aren't really worthwhile:

1. We can use autoconf.  In addition to all the reasons why this idea just
   sucks, the fact is that it won't solve our problem anyway because some
   cores have build dependencies, even if they should be free of external
   runtime dependencies.  Not only that, we cannot easily predict if down the
   line you want to use libretro-super to build a core out of a mercurial or
   subversion repository.

2. We could try to reinvent autoconf for our purposes.  This has the advantage
   that we could build a system that accommodates our build system's needs and
   also provides a means for cores to declare additional build dependencies if
   they need them.  It has the obvious disadvantage that no attempt to replace
   autoconf has ever really been successful for a reason.  Either you have to
   introduce an external dependency (as cmake did) or you have to mix a bunch
   of 1970s-era script syntaxes like autoconf does because they're the only
   ones you can guarantee are installed everywhere.

3. We can simply state our dependencies from the outset and expect the user of
   libretro-super to meet them.  We may have to jump through a few hoops to
   deal with where things are installed.  For example, our scripts might be
   best run using the same /usr/bin/env tactic used by Python developers to
   avoid hard-coding a path that isn't portable.  I'm told that the byuu, the
   primary developer behind bsnes/higan, has a philosophy of not limiting
   himself to legacy cruft when something better exists.  To the extent that
   is actually a reasonable thing to do, it's not a bad idea.

   This doesn't solve the core build dependency issue by itself, but it does
   assure that if the libretro-super user has installed the prerequisites for
   using libretro-super, we CAN solve that problem without resorting to the
   kind of abomination that is autoconf.

Obviously I see but one choice here.  However care needs to be exercised still
to ensure that our libretro-super dependencies are in fact __reasonable__.  I
would love to be able to take advantage of modern versions of bash, for
example, but Mac OS X users don't have it unless they installed it themselves.
It's not even guaranteed with MacPorts or Fink installed, so it's a different
issue than on Windows where people are going to have to install something no
matter what we use.

(Yes, I know bash 3 is ancient, but MacPorts and Fink both get along with it
just fine, and only bash scripters really ever notice the difference.  If you
want to convince Twinaphex that it's a reasonable dependency, I'll join you in
doing so—but if it isn't packaged for PowerPC 10.5 systems, he's going to veto
the idea from the start and so will I.  Yes, RetroArch doesn't currently build
on 10.5 systems.  If I can reasonably correct that at some point, I will.  No,
10.4 and older isn't necessary.)


## The solution so far

To begin, let's discuss the proof of concept I wrote before even beginning
this README.  We can decide where it goes from there afterward.  We'll be
using the incredibly simple 2048 project as a working example,  I like it
because it's as close to a fully functional "hello world" for libretro as I
can imagine.  Presently it fetches and compiles with these rules:

```bash
fetch_libretro_2048() {
   fetch_git "$REPO_BASE/libretro/libretro-2048.git" "libretro-2048" "libretro/2048"
}

build_libretro_2048() {
   build_libretro_generic_makefile "2048" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}
```

Okay, so I turned that into a pile of shell variables:

```bash
core_2048_dir="libretro-2048"
core_2048_fetch=fetch_git
core_2048_source="$REPO_BASE/libretro/libretro-2048.git"
core_2048_build_rule=build_libretro_generic_makefile_s
core_2048_makefile="Makefile.libretro"
core_2048_other_args="$FORMAT_COMPILER_TARGET"
```

There's no need for $REPO_BASE for "write access" using github, and github
actually recommends everyone use https anyway.  (They've flip-flopped on this
a few times over the years.)

The first real change here is build_libretro_generic_makefile_s, a version of
the build_libretro_generic_makefile rule written to use a set of shell
variables instead of positional parameters. You'll notice there's no variable
for subdir defined because no subdir is needed and therefore the rule doesn't
use one.

The fetch and build rules could be implicit as well since those would be the
defaults.  Actually, the only things 2048 uses that cannot be implicit
defaults are obviously the source repository and its use of something other
than ``makefile`` or ``Makefile``.

This proof of concept uses shell variables, but it could just as easily have
used an ini file format like so:

```ini
[2048]
source = "https://github.com/libretro/libretro-2048.git"
makefile = "Makefile.libretro"
```

or an RFC-822 style format ala Debian Packages files:

```
Core: 2048
Source: https://github.com/libretro/libretro-2048.git
Makefile: Makefile.libretro
```

or even possibly in the .info file:

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

I like the notion of the second option actually even better than the third.
I'll explain why when I get to XXX


## Where to go from here

We need a better replacement for $platform and $FORMAT_COMPILER_TARGET and its
often identical $FORMAT_COMPILER_TARGET_ALT.  I dunno about you, but my
primary workstation has three compiler suites installed that can collectively
generate code for two platforms and eight major processor architectures.  I
can currently run two of the processor architectures, compiled for either of
the two platforms.  I used to have a computer that could run three other
architectures on one of those platforms, but no longer do.  I have a Mac, and
as far as libretro is concerned a present, that's all grossly oversimplified
to just "osx".  WTF!  That's gotta be fixed.

Next, as already noted there's some confusion outside of libretro circles
about the scope of libretro, namely that it is intended to be first and
foremost an API to be implemented by programs called "players" and packages
called "cores".  If libretro-super is supposed to be an easy way to build
these things, then players and cores need to simply be definitions that you
can drop in to libretro-super and use, regardless of where they come from.


### A better platform designation

Currently the CPU you're building for is stored in the variable ARCH.  The
platform may be specified in a couple of different formats in the $platform
variable, and $FORMAT_COMPILER_TARGET and $FORMAT_COMPILER_TARGET_ALT in a
canonical format.  But as I said on my Mac will all its build possibilities
they all boil down to "osx".  At the very least, a platform designation should
be specified as a canonical pairing of an OS target and an architecture
target.  An evolution from what we have now would be to call my system
``MacOSX-x86_64``.  Other valid architectures for Mac OS X are i386, ppc,
ppc64, and ppc970.  (For those who don't know, ppc970 is compatible with ppc64
code, but not the other way around, though I don't know how important 64 bit
CPU support is on those G5 Macs with their typical RAM constraints.)

The best way would be to determine which compilers were available for a given
language and how to invoke them.  At least on my system Clang and one of the
gcc's should be picked up for C, C++, and Obj-C for pretty much every
standard.  And these would be defined for my current platform target of
MacOSX-x86_64.

But it shouldn't stop there.  On all modern x86_64 systems, it is possible to
compile an (usually) run iX86 code.  Our build system should determine if you
have the ability to do it and give you the option of doing so instead of or
addition to the x86_64 option.  Users don't need that, but developers do.

Likewise for PowerPC and ARM architectures, there might be more than one CPU
target possible.

Mac OS X and iOS introduce another spanner in the works in that they support
compiling these multiple targets and joining them together using a tool called
lipo.  The compiler will do this for you in most cases.  Basically if any
CPU-specific features are determined by reading system headers or
compiler-defined variables, you just specify -arch i386 -arch x86_64 on the
compiler and linker command lines and you get both in one library/program.  If
you're hard-coding things like whether to use 32 or 64 bit structures on the
command line \*cough\*mupen64plus\*cough\*, you're going to have to build it
twice and use lipo or better yet, patch the code to figure out these
structural differences from the compile environment provided.

We have some support for fat binaries on OS X currently, but it's a proof of
concept only that illustrates the limitations of our current build scripts
more than anything.


### Packages files

If libretro-super is going to be just a build environment for things built
around the libretro API in a highly scalable fashion, we need a way for people
to drop in their own fetch and build methods, as well as package rules for
players and cores.

Let's say the SuperTux developers port their game to libretro.  Pretty sweet
right?  In order to build this using libretro-super, you'd need a set of build
rules for it.  The SuperTux folks could provide you with a URL for a packages
file which you could either download and drop into libretro-super yourself, or
you could give the URL to libretro-super and let it download it for you.
(Dependency on either wget or curl there—everybody has at least one or the
other though so that's fine.)

If you do let libretro-super download it for you, it could periodically check
to see if it has changed and update it if needed.  Think apt-add-repository
from Ubuntu.  Key signing and verification is not yet planned, but if you can
come up with an intelligent and minimalistic way to do it, I'm interested. :)


### Actions and targets

At this point, libretro is a __MASSIVE__ project, which is kind of impressive
for something that's not really supposed to be a project at all.  There are
something approaching 70 individual cores including three versions of MAME,
three versions of standalone bSNES, and more.  Users do not need all of that.
The average developer doesn't even need all of that.  The only people who do
are the people running the buildbots that package all of the stuff that is
currently maintained by libretro developers.

The whole reason libretro-super exists is to give libretro developers an easy
way to build all of that stuff at once as it changes.  And the only people who
need to rebuild all of it from scratch are people like me who are working on
build system scripts.

If libretro-super is going to be the standard reference build environment used
for libretro cores and (perhaps also) players, not only does it need modular
build targets and rules, it needs to be configurable as to what it will do,
and what it will do it to.

The average end user only needs to fetch and build the cores they want.  They
might also want those cores installed into their player.  That needs to be
possible.

Buildbots need to fetch anything that has changed and then clean, build,
package, and release it.  For every supported platform.  That needs to be
possible.  :)

Developers working on any package (core or player) built using libretro-super
need to be able to run individual commands to perform individual tasks on a
particular package or group of packages.  That too needs to be possible.

Finally it is possible somewhere along the line that libretro-super might
itself be packaged and the only people running it out of a git repository will
be those choosing to do so.  Everyone else will have it installed somewhere on
their system.  The commands need to work outside of the libretro-super
directory, and the build system needs to be able to find anything currently
just tossed into the libretro-super directory if it has been installed onto
your system.  I won't say that this needs to be possible because to some
limited extent, it already is.  :)


### External sources

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


<!-- vim: set tw=78 ts=8 sw=8 noet ft=markdown spell: -->
