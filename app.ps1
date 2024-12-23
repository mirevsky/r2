param (
    [string]$command,
    [string]$arg1,
    [string]$arg2,
    [string]$arg3,
    [string]$arg4,
    [string]$arg5,
    [string]$arg6
)

function r2_logo {
    Write-Host "                       .--:::::::.                "
    Write-Host "                     --..::::.   :-:              "
    Write-Host "                    =.       .::::.:=             "
    Write-Host "                   =:::=-:-       .:-=            "
    Write-Host "                  =-::-= .+::=:::.   =.           "
    Write-Host "                 :-    .:=-:+.   .*  =            "
    Write-Host "                .=     --::-+=:::=::==            "
    Write-Host "                +     + .-:: =.  .:-+             "
    Write-Host "               =.     + :-:=  =    =              "
    Write-Host "              -:     .*.      =.  -.              "
    Write-Host "             :-      +.=      -: :-               "
    Write-Host "            .=      =. :-::::-= .=                "
    Write-Host "            +  :--:=-   :*.   + +                 "
    Write-Host "           :=::+   =-:::=.=   :+.                 "
    Write-Host "           .=  .::=+.     =.   +.                 "
    Write-Host "            .::::.  .::::.==::::--                "
    Write-Host "                =:::::.  .+      +                "
    Write-Host "               .+::.:-.:::==:::::=-               "
    Write-Host "               -: .=-      +......+               "
    Write-Host "             --::::=:     =:.......=.             "
    Write-Host "            +=::::::+=  .=  :-::--  -:            "
    Write-Host "            +::=::=::+  +:::=::::=:::+:           "
    Write-Host "                        =::::::::::::=            "
}

function r2_commands_list {
    Write-Host "+---------------------------------------------------------+"
    Write-Host "| R2 CLI - Command Line Interface                         |"
    Write-Host "+---------------------------------------------------------+"
    Write-Host "| r2 add <project-name>                                   |"
    Write-Host "| r2 run <project-name>                                   |"
    Write-Host "| r2 start <service-name>                                 |"
    Write-Host "| r2 stop <service-name>                                  |"
    Write-Host "| r2 stop all                                             |"
    Write-Host "| r2 setup <app-name>  (git | jira | openai)              |"
    Write-Host "| r2 delete all                                           |"
    Write-Host "| r2 ssh <service-name>                                   |"
    Write-Host "| r2 list                                                 |"
    Write-Host "| r2 update                                               |"
    Write-Host "| r2 d2 'Open AI chat...'                                 |"
    Write-Host "| r2 d2 sum <text>                                        |"
    Write-Host "+---------------------------------------------------------+"
    Write-Host "| r2 release <project-name> <jira-project-code> <version> |"
    Write-Host "+---------------------------------------------------------+"
}

function r2_openai_call {
    param (
        [string]$data
    )
    $template = '{ "model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "%s"}], "temperature": 0.7}'
    if ($data) {
        $result = Invoke-RestMethod -Uri "$OPENAI_URL/v1/chat/completions" -Headers @{ "Content-Type" = "application/json"; "Authorization" = "Bearer $OPENAI_API_KEY" } -Body ([System.String]::Format($template, $data)) -Method Post
        $result.choices | ForEach-Object { $_.message.content }
    }
}

function r2_jira_call {
    param (
        [string]$type,
        [string]$url,
        [string]$data
    )
    $result = Invoke-RestMethod -Uri "$JIRA_SYS_URL$url" -Headers @{ "Accept" = "application/json"; "Content-Type" = "application/json" } -Credential (New-Object System.Management.Automation.PSCredential("$JIRA_SYS_EMAIL", (ConvertTo-SecureString "$JIRA_API_KEY" -AsPlainText -Force))) -Body $data -Method $type
    return $result
}

function r2_jira_create_ticket {
    param (
        [string]$project,
        [string]$issuetype,
        [string]$summary,
        [string]$description
    )
    $template = @"
{
  "fields": {
     "project": {
        "key": "%s"
     },
     "summary": "%s",
     "description": {
       "type": "doc",
       "version": 1,
       "content": %s
      },
     "issuetype": {
        "name": "%s"
     }
    }
}
"@
    $result = r2_jira_call -type "POST" -url "rest/api/3/issue" -data ([System.String]::Format($template, $project, $summary, $description, $issuetype))
    return $result.key
}

function r2_jira_get_description {
    param (
        [string]$pr
    )
    $description = r2_jira_call -type "GET" -url "rest/api/2/issue/$pr?fields=description"
    return $description.fields.description
}

function r2_jira_create_release {
    param (
        [string]$project,
        [string]$name,
        [string]$description
    )
    $template = @"
{
   "archived": false,
   "description": "%s",
   "name": "%s",
   "project": "%s",
   "releaseDate": "%s",
   "released": false
}
"@
    r2_jira_call -type "POST" -url "rest/api/3/version" -data ([System.String]::Format($template, $description, $name, $project, (Get-Date -Format "yyyy-MM-dd")))
}

function r2_jira_tag_release {
    param (
        [string]$ticket,
        [string]$tag
    )
    $template = @"
{
    "update": {
      "fixVersions": [{
          "add": {"name": "%s"}
        }
      ]
    }
}
"@
    r2_jira_call -type "POST" -url "rest/api/2/issue/$ticket" -data ([System.String]::Format($template, $tag))
}

function r2_jira_move_ticket {
    param (
        [string]$ticket,
        [string]$transition
    )
    $template = '{"transition":{"id":%s}}'
    r2_jira_call -type "POST" -url "rest/api/3/issue/$ticket/transitions" -data ([System.String]::Format($template, $transition))
}

function r2_read {
    param (
        [string]$prompt
    )
    $set_read = Read-Host -Prompt $prompt
    return $set_read
}

function r2_msg {
    param (
        [string]$message
    )
    Write-Host $message
}

function r2_msg_info {
    param (
        [string]$message
    )
    Write-Host "$message"
}

function r2_msg_error {
    param (
        [string]$message
    )
    Write-Host "$message"
}

switch ($command) {
    "add" {
        git clone "$GIT_SYS_URL$arg1"
    }

    "release" {
        if (-not $arg1 -or -not $arg2 -or -not $arg3) {
            r2_msg_error "Additional parameters required!"
            exit
        }

        $project_name = $arg1
        $project_jira_code = $arg2
        $version = $arg3

        if ($arg4 -and $arg4 -eq "--non-interactive") {
            if (Test-Path -Path "~/.r2_config") {
                . "~/.r2_config"
                $R2_CONFIRM_RELEASE_TICKET = 'Y'
                $R2_RELEASE_CONFIRM = ''
                $R2_MOVE_JIRA_TICKET = ''
            } else {
                r2_msg_error "File ~/.r2_config does not exist!"
                exit
            }
        }

        if (-not (Test-Path -Path "$R2_WORKSPACE\$arg1")) {
            r2_msg_error "Directory does not exist!"
            exit
        }

        Set-Location -Path "$R2_WORKSPACE\$arg1"
        git fetch --all --quiet

        $exists = git show-ref "refs/heads/$version"
        if ($exists) {
            git checkout $version
            git pull
        } else {
            r2_msg_error "Release version $version does not exist!"
            exit
        }

        $main_branch = 'main'
        $exists = git show-ref "refs/heads/main"
        if ($exists) {
            git checkout main
            git pull
        }

        $exists = git show-ref "refs/heads/master"
        if ($exists) {
            $main_branch = 'master'
            git checkout master
            git pull
        }

        git checkout $version

        $list_branches = git log "$version...$main_branch" --decorate="full" | Select-String -Pattern "($project_jira_code)[- 0-9]*"

        if ($R2_DESCRIPTION) {
            $description = $R2_DESCRIPTION
        } else {
            $description = r2_read "Enter description for the release:"
        }
        r2_jira_create_release -project $project_jira_code -name $version -description $description

        $jira_prs = ""
        $jira_description = ""
        foreach ($pr in $list_branches) {
            r2_jira_tag_release -ticket $pr -tag $version
            $jira_prs += '{"type": "inlineCard","attrs":{"url":"'+$JIRA_SYS_URL+'browse/'+$pr+'"}},'
            $description_data = r2_jira_get_description -pr $pr
            $jira_description += $description_data
        }

        $jira_prs = $jira_prs.TrimEnd(',')

        if ($R2_CONFIRM_RELEASE_TICKET -eq "Y") {
            $confirm = $R2_CONFIRM_RELEASE_TICKET
        } else {
            $confirm = r2_read "Do you want to create release ticket [y/N]?"
        }

        $template_description = @"
        [
        {"type": "paragraph","content": [{"type": "text","text": "Summary: %s"}]},
        {"type": "paragraph", "content": [ %s ]}
        ]
"@

        if ($confirm -eq "Y" -or $confirm -eq "y") {
            if ($R2_PROJECT_JIRA_CODE) {
                $project_jira_code = $R2_PROJECT_JIRA_CODE
            } else {
                $project_jira_code = r2_read "Set JIRA project code:"
            }

            $prompt = 'Summarize the following text:' + $jira_description
            $prompt = $prompt.Replace('"', '')

            $template = '{ "model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "%s"}], "temperature": 0.7}'
            if ($prompt) {
                $openai_summary = Invoke-RestMethod -Uri "$OPENAI_URL/v1/chat/completions" -Headers @{
                    "Content-Type" = "application/json"
                    "Authorization" = "Bearer $OPENAI_API_KEY"
                } -Body ($template -f $prompt) -Method Post
                $openai_summary = $openai_summary.choices | ForEach-Object { $_.message.content }
                $openai_summary = $openai_summary.Replace('"', '')
            }
            $result = r2_jira_create_ticket -project $project_jira_code -issuetype "Story" -summary "Release-$version" -description ($template_description -f $openai_summary, $jira_prs)
            $result = $result.Replace('"', '')
            Write-Host "${JIRA_SYS_URL}browse/$result"

            if ($R2_MOVE_JIRA_TICKET -eq "Y") {
                $move_jira_ticket = $R2_MOVE_JIRA_TICKET
            } else {
                $move_jira_ticket = r2_read "Do you want to move the ticket from the backlog [y/N]?"
            }
            if ($move_jira_ticket -eq "Y" -or $move_jira_ticket -eq "y") {
                if ($R2_POSITION) {
                    $position = $R2_POSITION
                } else {
                    $position = r2_read "Specify the status value[number]:"
                }
                r2_jira_move_ticket -ticket $result -transition $position
            }
        }

        if ($R2_RELEASE_CONFIRM) {
            $confirm = $R2_RELEASE_CONFIRM
        } else {
            $confirm = r2_read "Do you want to create release pull request [y/N]?"
        }
        if ($confirm -eq "Y" -or $confirm -eq "y") {
            git pull "refs/heads/$version"
            git commit -m "$version"
            git push
        }
    }

    "delete" {
        switch ($arg1) {
            "all" {
                r2_msg "IMPORTANT: This action will prune all images and volumes!"
                $confirm = r2_read "Are you sure you want to clear your services? [y/N]:"

                if ($confirm -eq "Y" -or $confirm -eq "y") {
                    docker kill $(docker ps -q)
                    docker system prune
                    docker system prune --volumes
                    docker rmi $(docker images -a -q)
                    r2_msg_info "All containers have been completely removed..."
                    docker ps
                    r2_msg_info "Run r2 run <project-name>"
                }
            }
        }
    }

    "run" {
        if (Test-Path -Path "$R2_WORKSPACE\$arg1") {
            Set-Location "$R2_WORKSPACE\$arg1"
            docker-compose run "$arg2"
        } else {
            docker run $(docker ps -aqf "name=^$arg1")
        }
    }

    "restart" {
        switch ($arg1) {
            "all" {
                docker restart $(docker ps -q)
            }
            default {
                if (Test-Path -Path "$R2_WORKSPACE\$arg1") {
                    Set-Location "$R2_WORKSPACE\$arg1"
                    docker-compose restart "$arg2"
                } else {
                    docker restart $(docker ps -aqf "name=^$arg1")
                }
            }
        }
    }

    "ssh" {
        docker exec -it $(docker ps -aqf "name=^$arg1") /bin/bash
    }

    "exec" {
        docker exec -it $(docker ps -aqf "name=^$arg1") /bin/bash -c "$arg2 $arg3 $arg4 $arg5 $arg6"
    }

    "stop" {
        switch ($arg1) {
            "all" {
                docker kill $(docker ps -q)
            }
            default {
                if (Test-Path -Path "$R2_WORKSPACE\$arg1") {
                    Set-Location "$R2_WORKSPACE\$arg1"
                    docker-compose stop "$arg2"
                } else {
                    docker kill $(docker ps -aqf "name=^$arg1")
                }
            }
        }
    }

    "list" {
        docker ps
    }

    "update" {
        if (Test-Path -Path "$R2_WORKSPACE/r2") {
            Set-Location "$R2_WORKSPACE/r2"
            git pull
            Copy-Item -Path "app.ps1" -Destination "$R2_WORKSPACE/../.r2.ps1"
        }
    }

    "d2" {
        switch ($arg1) {
            "sum" {
                $result = r2_openai_call "Summarize the following text: $arg2"
                Write-Host $result
            }
            default {
                $result = r2_openai_call "$arg1"
                Write-Host $result
            }
        }
    }

    "setup" {
        switch ($arg1) {
            "git" {
                choco install git.install
                choco install jq

                $confirm = r2_read "Do you want to generate ssh key? [y/N]:"
                if ($confirm -eq "Y" -or $confirm -eq "y") {
                    $ssh_type = r2_read "Select type[ed25519,rsa]:"
                    $ssh_email = r2_read "Set user email:"
                    ssh-keygen -t $ssh_type -C "$ssh_email"
                    r2_msg "SSH key was generated! Please copy/paste the key below and add into your Github Account."
                    Get-Content -Path "$HOME/.ssh/id_$ssh_type.pub"
                }

                $GIT_SYS_URL = r2_read "GIT Url:"
            }

            "jira" {
                $JIRA_SYS_URL = r2_read "JIRA Url:"
                $JIRA_SYS_EMAIL = r2_read "JIRA User email:"
                $JIRA_API_KEY = r2_read "JIRA API Key:"
            }

            "openai" {
                r2_msg_info "Note: OpenAI default url is https://api.openai.com"
                $OPENAI_URL = r2_read "OpenAI URL:"
                $OPENAI_API_KEY = r2_read "OpenAI API Key:"
            }

            "nvm" {
                choco install nvm
            }

            "pyenv" {
                choco install pyenv-win
            }

            "choco" {
                Get-Help Set-ExecutionPolicy
                Set-ExecutionPolicy AllSigned
                Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            }

            "go" {
                choco install go
            }

            "devtools" {
                choco install pycharm
                choco install vscode
                choco install beekeeper-studio.install
            }

            "social" {
                choco install signal
            }

            "jq" {
                choco install jq
            }
        }
    }

    "help" {
        switch ($arg1) {
            "apps" {
                r2_logo
                r2_msg "r2 setup nvm"
                r2_msg "r2 setup pyenv"
                r2_msg "r2 setup choco"
                r2_msg "r2 setup go"
                r2_msg "r2 setup openai"
                r2_msg "r2 setup jira"
                r2_msg "r2 setup jq"
                r2_msg "r2 setup devtools"
                r2_msg "r2 setup social"
            }
            default {
                r2_logo
                r2_commands_list
            }
        }
    }
}