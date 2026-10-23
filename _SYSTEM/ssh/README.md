# SSH config
Target directory: `/etc/ssh/`

_FOR REFERENCE ONLY_
^^ The system config is fine, but the user drop-ins would define keys that, even if I only expose the public key, should not be reused across different systems....that defeats their purpose.

SSH defaults to some antiquated locations. Thus, my configuration seeks to establish the following directory hierarchy for host-specific configuration (and keys, included for a complete context.)

```
/home/.config/
| ssh/
    | conf.d/
        | 10-host-a.conf
        | 10-host-b.conf
        | ...
        | 99-global.conf
    | hosts.d/
    | keys.d/
        | host-a/
        | host-b/
        | ...
        | global/
```

Note that this structure is _actually_ enforced by each of the configs in the user drop-ins. Refer to `99-global.conf` in the normal catalyst dotfiles.

### `ssh_config`

_**NOTE:** while `XDG_CONFIG_HOME` expands as expected, the advanced fallback syntax (i.e., `:-/root`) does not appear to be supported by SSH, so this will always break when running as root, as none of my scripts give root any such environment variable. That said, I don't believe that I **should** run ever SSH as root anyway._
