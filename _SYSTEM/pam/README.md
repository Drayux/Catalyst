# PAM config
Target directory: `/etc/pam.d/`

_FOR REFERENCE ONLY_

Do **not** blindly copy this configuration. It may lock you out of the system until the `pam_rundir` module is installed.

Note that this config merges with any number of defaults already present in this directory.

### `system-login`

This config file features a key change to incorporate the use of an additional PAM module (pam_rundir, per my curated install steps.) This module handles the user's runtime directory and corresponding environment variable in lieu of elogind.
