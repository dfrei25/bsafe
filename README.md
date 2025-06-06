# bJail

a lightweight rootless profile based sandbox solution using bwrap.

*(Firejail profile usage is optionally supported, but Firejail has to be installed separately. This will grant access to a much larger set of whitelisted files/directories.)*

## Running the sandbox

To start the sandbox, prefix your command with `bJail`:

```bash
bJail firefox            # starting Mozilla Firefox
bJail --help             # show usage and examples
bJail -d -s discord      # dryrun & print the bwrap command that would be executed starting discord
bJail -p=firefox bash    # launch a shell with firefox profile active
```

## Compared startup time
![podman firejail and bJail startup times compared](/assets/images/startuptime.jpg)

## Profile demo
![home folder files visible to sandboxed firefox](/assets/images/profiledemo.jpg)


## Todo:
- Seccomp fine gained support is planed, utilizing bwraps `--seccomp` feature.
- As this project started locally as a little personal script, future rework will be done increasing readability
- split the script into more files, making it easier to maintain
- find a better parsing solution for firejail profiles, add ${PICTURES} ${VIDEOS} and possibly other missed variables.
- implement suggestions from #bash irc
- awaiting feedback/adding community ideas
