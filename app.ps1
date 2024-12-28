param (
    [string]$command,
    [string]$arg1,
    [string]$arg2,
    [string]$arg3,
    [string]$arg4,
    [string]$arg5,
    [string]$arg6
)

function r2_logo
{
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

function r2_commands_list
{
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

function r2_append_var
{
    param(
        [string]$v
    )
    $Env:PATH += ";" + $v
    [Environment]::SetEnvironmentVariable('PATH', $Env:PATH, [System.EnvironmentVariableTarget]::Machine)
}

function r2_openai_call
{
    param (
        [string]$data
    )
    $template = @"
{
    "model": "gpt-3.5-turbo",
    "messages": [{
        "role": "user",
        "content": "$data"
    }],
    "temperature": 0.7
}
"@
    if ($data)
    {
        $pathArray = $Env:Path -split ';'
        $variable = $pathArray -match 'OPENAI_URL'
        $value = $variable -split '='
        $OPENAI_URL = $value[1]

        $pathArray = $Env:Path -split ';'
        $variable = $pathArray -match 'OPENAI_API_KEY'
        $value = $variable -split '='
        $OPENAI_API_KEY = $value[1]

        $template = (ConvertFrom-Json $template) | ConvertTo-Json -Compress

        $result = Invoke-RestMethod -Uri "$OPENAI_URL/v1/chat/completions" -Headers @{ "Content-Type" = "application/json"; "Authorization" = "Bearer $OPENAI_API_KEY" } -Body $template -Method Post
        $result.choices | ForEach-Object { $_.message.content }
    }
}

function r2_jira_call
{
    param (
        [string]$type,
        [string]$url,
        [string]$data
    )
    $pathArray = $Env:Path -split ';'
    $variable = $pathArray -match 'JIRA_SYS_URL'
    $value = $variable -split '=', 2
    $JIRA_SYS_URL = $value[1]

    $pathArray = $Env:Path -split ';'
    $variable = $pathArray -match 'JIRA_SYS_EMAIL'
    $value = $variable -split '=', 2
    $JIRA_SYS_EMAIL = $value[1]

    $pathArray = $Env:Path -split ';'
    $variable = $pathArray -match 'JIRA_API_KEY'
    $value = $variable -split '=', 2
    $JIRA_API_KEY = $value[1]
    $JIRA_API_KEY = $JIRA_API_KEY.Replace('"', '')

    # Create a credential object
    $credentials = "${JIRA_SYS_EMAIL}:${JIRA_API_KEY}"
    $encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))

    $headers = @{
        Accept = "application/json";
        "Content-Type" = "application/json";
        Authorization = "Basic $encodedCredentials"
    }

    if ($type -eq "GET") {
        $result = Invoke-RestMethod -Uri "$JIRA_SYS_URL$url" -Headers $headers -Method $type
    }else{
        $body = @"
$data
"@
        $result = Invoke-RestMethod -Uri "$JIRA_SYS_URL$url" -Headers $headers -Body $body -Method $type
    }
    return $result | ConvertTo-Json
}

function r2_jira_create_ticket
{
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
        "key": "$project"
     },
     "summary": "$summary",
     "description": {
       "type": "doc",
       "version": 1,
       "content": $description
      },
     "issuetype": {
        "name": "$issuetype"
     }
    }
}
"@

    $template = $template | ConvertTo-Json | ConvertFrom-Json
    $result = r2_jira_call -type "POST" -url "rest/api/3/issue" -data $template
    $result = $result | ConvertFrom-Json
    return $result.key
}

function r2_jira_get_description
{
    param (
        [string]$pr
    )
    $pr = $pr.Trim()
    $description = r2_jira_call "GET" "rest/api/2/issue/${pr}?fields=description"
    $description = $description | ConvertFrom-Json
    return $description.fields.description
}

function r2_jira_create_release
{
    param (
        [string]$project,
        [string]$name,
        [string]$description
    )
    $date = (Get-Date -Format "yyyy-MM-dd")
    $template = @"
{
   "archived": false,
   "description": "$description",
   "name": "$name",
   "project": "$project",
   "releaseDate": "$date",
   "released": false
}
"@
    r2_jira_call -type "POST" -url "rest/api/3/version" -data $template
}

function r2_jira_tag_release
{
    param (
        [string]$ticket,
        [string]$tag
    )
    $template = @"
{
    "update": {
        "fixVersions": [
            {"add": { "name":"$tag" }}
        ]
    }
}
"@

    r2_jira_call -type "PUT" -url "rest/api/2/issue/$ticket" -data $template
}

function r2_jira_move_ticket
{
    param (
        [string]$ticket,
        [string]$transition
    )
    $template = '{"transition":{"id":' + $transition + '}}'
    r2_jira_call -type "POST" -url "rest/api/3/issue/$ticket/transitions" -data $template
}

function r2_read
{
    param (
        [string]$prompt
    )
    $set_read = Read-Host -Prompt $prompt
    return $set_read
}

function r2_msg
{
    param (
        [string]$message
    )
    Write-Host $message
}

function r2_msg_info
{
    param (
        [string]$message
    )
    Write-Host "$message"
}

function r2_msg_error
{
    param (
        [string]$message
    )
    Write-Host "$message"
}

switch ($command)
{
    "add" {
        git clone "$GIT_SYS_URL$arg1"
    }

    "release" {
        if (-not $arg1 -or -not $arg2 -or -not $arg3)
        {
            r2_msg_error "Additional parameters required!"
            exit
        }

        $pathArray = $Env:Path -split ';'
        $variable = $pathArray -match 'JIRA_SYS_URL'
        $value = $variable -split '=', 2
        $JIRA_SYS_URL = $value[1]

        $project_name = $arg1
        $project_jira_code = $arg2
        $version = $arg3

        if ($arg4 -and $arg4 -eq "--non-interactive")
        {
            if (Test-Path -Path "~/.r2_config")
            {
                . "~/.r2_config"
                $R2_CONFIRM_RELEASE_TICKET = 'Y'
                $R2_RELEASE_CONFIRM = ''
                $R2_MOVE_JIRA_TICKET = ''
            }
            else
            {
                r2_msg_error "File ~/.r2_config does not exist!"
                exit
            }
        }

        if (-not (Test-Path -Path "$R2_WORKSPACE\$arg1"))
        {
            r2_msg_error "Directory does not exist!"
            exit
        }

        Set-Location -Path "$R2_WORKSPACE\$arg1"
        git fetch --all --quiet

        $exists = git show-ref "refs/heads/$version"
        if ($exists)
        {
            git checkout $version
            git pull
        }
        else
        {
            r2_msg_error "Release version $version does not exist!"
            exit
        }

        $main_branch = 'main'
        $exists = git show-ref "refs/heads/main"
        if ($exists)
        {
            git checkout main
            git pull
        }

        $exists = git show-ref "refs/heads/master"
        if ($exists)
        {
            $main_branch = 'master'
            git checkout master
            git pull
        }

        git checkout $version

        $list_branches = git log "$version...$main_branch" --decorate="full" | Select-String -Pattern "($project_jira_code)[- 0-9]*" -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

        if ($R2_DESCRIPTION)
        {
            $description = $R2_DESCRIPTION
        }
        else
        {
            $description = r2_read "Enter description for the release:"
        }
        r2_jira_create_release $project_jira_code $version $description

        $jira_prs = ""
        $jira_description = ""
        foreach ($pr in $list_branches)
        {
            r2_jira_tag_release $pr $version
            $jira_prs += '{"type": "inlineCard","attrs":{"url":"' + $JIRA_SYS_URL + 'browse/' + $pr + '"}},'
            $description_data = r2_jira_get_description $pr
            $jira_description += $description_data
        }

        $jira_prs = $jira_prs.TrimEnd(',')

        if ($R2_CONFIRM_RELEASE_TICKET -eq "Y")
        {
            $confirm = $R2_CONFIRM_RELEASE_TICKET
        }
        else
        {
            $confirm = r2_read "Do you want to create release ticket [y/N]?"
        }

        if ($confirm -eq "Y" -or $confirm -eq "y")
        {
            if ($R2_PROJECT_JIRA_CODE)
            {
                $project_jira_code = $R2_PROJECT_JIRA_CODE
            }
            else
            {
                $project_jira_code = r2_read "Set JIRA project code:"
            }
            $jira_description = $jira_description.Replace('"', '')
            $prompt = @"
Summarize the following text:$jira_description
"@
            $prompt = $prompt.Replace('"', '').Trim()
            $openai_summary = r2_openai_call "$prompt"
            $template_description = @"
        [
        {"type": "paragraph","content": [{"type": "text","text": "Summary: $openai_summary"}]},
        {"type": "paragraph", "content": [ $jira_prs ]}
        ]
"@
            $result = r2_jira_create_ticket $project_jira_code "Story" "Release-$version"  $template_description
            Write-Host $JIRA_SYS_URL + 'browse/' + $result
            if ($R2_MOVE_JIRA_TICKET -eq "Y")
            {
                $move_jira_ticket = $R2_MOVE_JIRA_TICKET
            }
            else
            {
                $move_jira_ticket = r2_read "Do you want to move the ticket from the backlog [y/N]?"
            }
            if ($move_jira_ticket -eq "Y" -or $move_jira_ticket -eq "y")
            {
                if ($R2_POSITION)
                {
                    $position = $R2_POSITION
                }
                else
                {
                    $position = r2_read "Specify the status value[number]:"
                }
                r2_jira_move_ticket -ticket $result -transition $position
            }
        }

        if ($R2_RELEASE_CONFIRM)
        {
            $confirm = $R2_RELEASE_CONFIRM
        }
        else
        {
            $confirm = r2_read "Do you want to create release pull request [y/N]?"
        }
        if ($confirm -eq "Y" -or $confirm -eq "y")
        {
            git pull "refs/heads/$version"
            git commit -m "$version"
            git push
        }
    }

    "delete" {
        switch ($arg1)
        {
            "all" {
                r2_msg "IMPORTANT: This action will prune all images and volumes!"
                $confirm = r2_read "Are you sure you want to clear your services? [y/N]:"

                if ($confirm -eq "Y" -or $confirm -eq "y")
                {
                    docker kill $( docker ps -q )
                    docker system prune
                    docker system prune --volumes
                    docker rmi $( docker images -a -q )
                    r2_msg_info "All containers have been completely removed..."
                    docker ps
                    r2_msg_info "Run r2 run <project-name>"
                }
            }
        }
    }

    "run" {
        if (Test-Path -Path "$R2_WORKSPACE\$arg1")
        {
            Set-Location "$R2_WORKSPACE\$arg1"
            docker-compose run "$arg2"
        }
        else
        {
            docker run $( docker ps -aqf "name=^$arg1" )
        }
    }

    "restart" {
        switch ($arg1)
        {
            "all" {
                docker restart $( docker ps -q )
            }
            default {
                if (Test-Path -Path "$R2_WORKSPACE\$arg1")
                {
                    Set-Location "$R2_WORKSPACE\$arg1"
                    docker-compose restart "$arg2"
                }
                else
                {
                    docker restart $( docker ps -aqf "name=^$arg1" )
                }
            }
        }
    }

    "ssh" {
        docker exec -it $( docker ps -aqf "name=^$arg1" ) /bin/bash
    }

    "exec" {
        docker exec -it $( docker ps -aqf "name=^$arg1" ) /bin/bash -c "$arg2 $arg3 $arg4 $arg5 $arg6"
    }

    "stop" {
        switch ($arg1)
        {
            "all" {
                docker kill $( docker ps -q )
            }
            default {
                if (Test-Path -Path "$R2_WORKSPACE\$arg1")
                {
                    Set-Location "$R2_WORKSPACE\$arg1"
                    docker-compose stop "$arg2"
                }
                else
                {
                    docker kill $( docker ps -aqf "name=^$arg1" )
                }
            }
        }
    }

    "list" {
        docker ps
    }

    "update" {
        if (Test-Path -Path "$R2_WORKSPACE/r2")
        {
            Set-Location "$R2_WORKSPACE/r2"
            git pull
            Copy-Item -Path "app.ps1" -Destination "$R2_WORKSPACE/../.r2.ps1"
        }
    }

    "d2" {
        switch ($arg1)
        {
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
        switch ($arg1)
        {
            "git" {
                choco install git.install
                choco install jq

                $confirm = r2_read "Do you want to generate ssh key? [y/N]:"
                if ($confirm -eq "Y" -or $confirm -eq "y")
                {
                    $ssh_type = r2_read "Select type[ed25519,rsa]:"
                    $ssh_email = r2_read "Set user email:"
                    ssh-keygen -t $ssh_type -C "$ssh_email"
                    r2_msg "SSH key was generated! Please copy/paste the key below and add into your Github Account."
                    Get-Content -Path "$HOME/.ssh/id_$ssh_type.pub"
                }

                $GIT_SYS_URL = r2_read "GIT Url:"
                r2_append_var "GIT_SYS_URL=$GIT_SYS_URL"
            }

            "jira" {
                $JIRA_SYS_URL = r2_read "JIRA Url:"
                $JIRA_SYS_EMAIL = r2_read "JIRA User email:"
                $JIRA_API_KEY = r2_read "JIRA API Key:"
                r2_append_var "JIRA_SYS_URL=$JIRA_SYS_URL"
                r2_append_var "JIRA_SYS_EMAIL=$JIRA_SYS_EMAIL"
                r2_append_var "JIRA_API_KEY=$JIRA_API_KEY"
            }

            "openai" {
                r2_msg_info "Note: OpenAI default url is https://api.openai.com"
                $OPENAI_URL = r2_read "OpenAI URL:"
                $OPENAI_API_KEY = r2_read "OpenAI API Key:"
                r2_append_var "OPENAI_URL=$OPENAI_URL"
                r2_append_var "OPENAI_API_KEY=$OPENAI_API_KEY"
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
        switch ($arg1)
        {
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