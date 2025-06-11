# bsafe

a lightweight rootless profile based sandbox solution using bwrap.

*(Firejail profile usage is optionally supported, but Firejail has to be installed separately. This will grant access to a much larger set of whitelisted files/directories.)*

## Running the sandbox

To start the sandbox, prefix your command with `bsafe`:

```bash
bsafe firefox            # starting Mozilla Firefox
bsafe --help             # show usage and examples
bsafe -d -s discord      # dryrun & print the bwrap command that would be executed starting discord
bsafe -p=firefox bash    # launch a shell with firefox profile active
```

## Compared startup time
![podman firejail and bsafe startup times compared](/assets/images/startuptime.jpg)

## Profile demo
![home folder files visible to sandboxed firefox](/assets/images/profiledemo.jpg)


## Todo:
- As this project started locally as a little personal script, future rework will be done increasing readability
- split the script into more files, making it easier to maintain
- add seccomp ${PICTURES} ${VIDEOS} and possibly other missed variables/directives to firejail parsing
- awaiting feedback/adding community ideas

## Credits
- Thanks to Soliton, Earnestly, ano, monkfish and izabera from [#bash on libra.chat irc]
- Special thanks to Earnestly for the code rework, which brought new ideas to the code
