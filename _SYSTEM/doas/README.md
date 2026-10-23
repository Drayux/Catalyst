# Doas config
Target directory: `/etc/`

Simple configuration for doas!

That said, a note of an important caveat: the order of these lines **does** matter. The first is the simple "allow users of the `wheel` group to use their password to elevate permissions." The second is much more nuanced.

This allows users of the `video` group to run that _exact_ command line, here this points to a script I've written for special greetd behavior. Obligatory notice, yes, this could be a security flaw if that script were to be replaced with a symbolic link or something, but I am not too concerned for this system.
