## R2 CLI (Command Line Interface)

Unlock the ultimate developer toolkit with R2 CLI! Seamlessly integrating Docker, JIRA, and GIT, R2 CLI transforms your command line experience into a powerhouse of productivity. Simplify your workflow, streamline project management, and boost your version control efficiency—all in one robust interface. R2 CLI is designed to empower developers like you to achieve more with less hassle. Ready to revolutionize your development process? Try R2 CLI today and elevate your command line capabilities to new heights!

```text
                       .--:::::::.
                     --..::::.   :-:
                    =.       .::::.:=
                   =:::=-:-       .:-=
                  =-::-= .+::=:::.   =.
                 :-    .:=-:+.   .*  =
                .=     --::-+=:::=::==
                +     + .-:: =.  .:-+
               =.     + :-:=  =    =
              -:     .*.      =.  -.
             :-      +.=      -: :-
            .=      =. :-::::-= .=
            +  :--:=-   :*.   + +
           :=::+   =-:::=.=   :+.
           .=  .::=+.     =.   +.
            .::::.  .::::.==::::--
                =:::::.  .+      +
               .+::.:-.:::==:::::=-
               -: .=-      +......+
             --::::=:     =:.......=.
            +=::::::+=  .=  :-::--  -:
            +::=::=::+  +:::=::::=:::+:
                        =::::::::::::=
+---------------------------------------------------------+
| R2 CLI - Command Line Interface                         |
+---------------------------------------------------------+
| r2 add <project-name>                                   |
| r2 run <project-name>                                   |
| r2 start <service-name>                                 |
| r2 stop <service-name>                                  |
| r2 stop all                                             |
| r2 setup <app-name>  (git | jira | openai)              |
| r2 delete all                                           |
| r2 ssh <service-name>                                   |
| r2 list                                                 |
| r2 update                                               |
| r2 d2 'Open AI chat...'                                 |
| r2 d2 sum <text>                                        |
+---------------------------------------------------------+
| r2 kube <command>                                       |
+---------------------------------------------------------+
| r2 release <project-name> <jira-project-code> <version> |
+---------------------------------------------------------+
```

## Installation steps

```text
chmod +x ./install.sh
./install.sh
source ~/.bashrc

r2 help
r2 help apps

r2 setup minikube
r2 setup git
r2 setup homebrew
r2 setup jq
r2 setup jira
r2 setup openai
r2 setup minikube
```
Note: Clone the project into your Workspace so you can manage multiple projects.

### Non-Interactive Mode

This setting can be utilized in GitHub Actions to automate the release process, ensuring the script successfully processes by requiring a configuration file.

```text
r2 release <project-name> <jira-project-code> <version> --non-interactive
```

Example of `~/.r2_config` file.
```text
export R2_DESCRIPTION="Release description is here!"
export R2_PROJECT_JIRA_CODE="R2D2"
export R2_MOVE_JIRA_TICKET=Y # state is Y or N
export R2_POSITION=100
export R2_RELEASE_CONFIRM='N' # state is Y or N
```

Let me know if you like the tool and you want to see more automation...
email: lorandite@proton.me , please add subject: R2-D2 CLI improvement

---
## Windows installation

Run powershell as Administrator and Run `win-install.ps1`. This script will setup doskey `r2` and create `.r2.ps1` file in your main project directory.
Then run `r2 setup choco`. This will install chocolatey (https://chocolatey.org/) if you encounter any issue please follow the instruction from the chocolatey website.
After successful installation run `r2 setup git` , make sure you've enabled OpenSSH Client.
Make sure you follow the next steps:
```text
r2 setup jq
r2 setup jira
r2 setup openai
r2 setup minikube
```