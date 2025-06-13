# bsafe

a lightweight rootless profile based sandbox solution using bwrap.

- *Firejail profile usage is optionally supported, but Firejail has to be installed separately. This will grant access to a much larger set of whitelisted files/directories.*
- *syscall filtering is optionally supported, but you need to have libseccomp installed for compiling the required helper program.*

## Running the sandbox

To start the sandbox, prefix your command with `bsafe`:

```bash
bsafe firefox            # starting Mozilla Firefox
bsafe --help             # show usage and examples
bsafe -d discord         # dryrun - print the bwrap command that would be executed starting discord and exit.
bsafe -p=firefox bash    # launch a shell with firefox profile active
bsafe -s bash            # start a bash shell with seccomp filtering disabled
```

## Compared startup time
![podman firejail and bsafe startup times compared](/assets/images/startuptime.jpg)

## Profile demo
![home folder files visible to sandboxed firefox](/assets/images/profiledemo.jpg)

## Blocked syscall demo
![home folder files visible to sandboxed firefox](/assets/images/seccompdemo.jpg)


## Todo:
- As this project started locally as a little personal script, future rework will be done increasing readability
- add seccomp ${PICTURES} ${VIDEOS} and possibly other missed variables/directives to firejail parsing
- awaiting feedback/adding community ideas

## Credits
- Thanks to Soliton, greycat, Earnestly, ano, monkfish and izabera from [#bash on libra.chat irc]
- Special thanks to Earnestly for the code rework, which brought new ideas to the code
