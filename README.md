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
| r2 release <project-name> <jira-project-code> <version> |
+---------------------------------------------------------+
```

INSTALLATION STEPS

```text
chmod +x ./install.sh
./install.sh
source ~/.bashrc

r2 help
r2 help apps

r2 setup git
r2 setup homebrew
r2 setup jq
r2 setup jira
r2 setup openai
```
Note: Clone the project into your Workspace so you can manage multiple projects.