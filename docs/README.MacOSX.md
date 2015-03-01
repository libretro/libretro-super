# Requirements for libretro-super on OS X

As of this writing, OS X support for libretro-super requires use of a Terminal
application.  You'll also need Apple's Xcode, a set of command line tools for
your versionf of Xcode, and possibly also the source code management tool git.

## OS X 10.7 Lion and later

As of OS X 10.7, the correct way to get Xcode is via the Mac App Store.  If
you've been keeping up with OS X versions, you may simply go to the App Store
page for [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) and
click the friendly GET or iCloud download button, as appropriate.  An annoying
bug recently observed (as of 2015 February) is that you cannot download old
versions of App Store programs unless you have already "purchased" the app.

In that case, go to [Apple Developer Connection](http://developer.apple.com/)
and find it there.  It's buried and Apple tends to move it around
periodically, sorry.

Once you have installed Xcode (version 4+), open it and go into Preferences.
Select the Downloads pane, and click the Install button for Command Line
Tools.  Every time you upgrade Xcode, you'll want to back here to see if
Command Line Tools needs upgrading.

Once you've done that, check the section below about ``git``.


## OS X 10.5 Leopard and 10.6 Snow Leopard (and older?)

While the final versionf of OS X 10.6 did feature the Mac App Store, Xcode for
these versions generally came with the system installation media or a retail
OS X install disc.  Even so, a more recent version is probably available for
you at [Apple Developer Connection](http://developer.apple.com/) and it's
generally wise to have the latest version intended for your OS version.  OS X
Leopard can use up to Xcode 3.1 versions, which are the last ones to run
natively on PowerPC and the first to support compiling for iPhoneOS (yes,
pre-iPad!)

Xcode 3.2 is still able to compile PowerPC binaries, however like the OS X
Snow Leopard it runs on, you'll need an Intel processor to use it.

Older versions of OS X are not officially supported at this time, but if you
are more technically inclined, you might be able to make it work.  If you get
it to work, please send us a patch!  Obviously any version of Xcode predating
10.4.6 will not support Intel processors.

You will need to install git if you haven't already done so.

## git

On recent versions of OS X, you may already have git installed by Apple.  To
check, open up a terminal and type the command (without quotes) "``which
git``".  If you get another shell prompt without any output, you definitely
need to install git.  If you see a UNIX path name to git, then you're probably
good to go.  ``/usr/bin/git`` is the version supplied by Apple.  If it lives
somewhere else it was either compiled by hand or installed by source ports
system.  If you don't have it, a source ports system is a good way to get it.
Here's a few choices:

 * [MacPorts](http://www.macports.org/)
 * [HomeBrew](http://brew.sh/)
 * [Fink](http://www.finkproject.org/)

Of these, Fink tends to be the heaviest and HomeBrew the lightest.

One common criticism of HomeBrew is that using it tends to suggest downloading
ruby scripts right off the Internet and running them sight-unseen, with admin
access to your system.  If that sounds unwise, HomeBrew isn't for you.  That
said, think about the last commercial program you installed on your Mac.  Did
you look at its source code before verifying it was safe to run after you
downloaded it off the Internet?

MacPorts is somewhere in the middle, depending on how good you are at cleaning
up old "inactive" versions of things (use ``port -cu upgrade outdated`` when
you upgrade to keep things tidy.)  Your author uses MacPorts for all but a
couple of rare items not packaged by that port system.  That and check a
port's variants before installing it to make sure it has the features you
want, and disables the ones you don't.

Fink tends to follow the Debian model, which means lots of libraries needed
for optional features, just in case.  That's disk space used on a release
version, and lots of time compiling all of those libs if you are running a
pre-release.

Or you could just go and find git's website, download it, and follow the
instructions.  A basic Mac with Xcode installed probably meets all necessary
requirements.

<!-- FIXME: Too much handholding here? -->


# Using libretro-super

TODO: Works the same as libretro-super for Linux or under MSYS2 from here.
Document what that means exactly, later.

Nutshell version:

 * ``git clone https://github.com/libretro/libretro-super.git && cd libretro-super``
   or
   ``cd ~/path/to/libretro-super``
 * ``./libretro-upgrade.sh``
 * ``./libretro-fetch.sh``
 * ``./libretro-build.sh``

You get the idea.  You shouldn't need to run libretro-upgrade.sh after a fresh
clone—it's there to handle cross-module moves, renames, and deletions that git
cannot handle.

<!-- vim: set tw=78 ft=markdown: -->
