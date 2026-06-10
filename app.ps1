param (
    [string]$command,
    [string]$arg1,
    [string]$arg2,
    [string]$arg3,
    [string]$arg4,
    [string]$arg5,
    [string]$arg6
)

# Color definitions
$COLOR_BLACK = "`e[0;30m"
$COLOR_DARK_GREY = "`e[1;30m"
$COLOR_RED = "`e[0;31m"
$COLOR_LIGHT_RED = "`e[1;31m"
$COLOR_GREEN = "`e[0;32m"
$COLOR_LIGHT_GREEN = "`e[1;32m"
$COLOR_BROWN_ORANGE = "`e[0;33m"
$COLOR_YELLOW = "`e[1;33m"
$COLOR_BLUE = "`e[0;34m"
$COLOR_LIGHT_BLUE = "`e[1;34m"
$COLOR_PURPLE = "`e[0;35m"
$COLOR_LIGHT_PURPLE = "`e[1;35m"
$COLOR_CYAN = "`e[0;36m"
$COLOR_LIGHT_CYAN = "`e[1;36m"
$COLOR_LIGHT_GRAY = "`e[0;37m"
$COLOR_WHITE = "`e[1;37m"
$COLOR_NO = "`e[0m"

function r2_logo
{
    Write-Host "${COLOR_LIGHT_GRAY}                       .--${COLOR_LIGHT_BLUE}:::::::${COLOR_LIGHT_GRAY}.                ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}                     --${COLOR_LIGHT_BLUE}..::::.${COLOR_LIGHT_GRAY}   :-:              ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}                    =.       ${COLOR_LIGHT_BLUE}.::::.:${COLOR_LIGHT_GRAY}=             ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}                   =${COLOR_LIGHT_BLUE}:::=-:-       ${COLOR_LIGHT_GRAY}.:-=            ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}                  =-::-= .${COLOR_LIGHT_BLUE}+::=:::.   ${COLOR_LIGHT_GRAY}=.           ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}                 :-    .:=-:+.   .*  =            ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}                .=     --::-+=:::${COLOR_LIGHT_BLUE}=::${COLOR_LIGHT_GRAY}==            ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}                +     + .-:: =.  .:-+             ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}               =.     + :-:=  =    =              ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}              -:     .*.      =.  -.              ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}             :-      +.=      -: :-               ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}            .=      =. :-::::-= .=                ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}            +  ${COLOR_LIGHT_BLUE}:--:${COLOR_LIGHT_GRAY}=-   :*.   + +                 ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}           :=::+   =-${COLOR_LIGHT_BLUE}:::${COLOR_LIGHT_GRAY}=.=   :+.                 ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}           .=  .::=+.     =.   +.                 ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}            .::::.  .::::.==::::--                ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}                =:::::.  .+      +                ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}               .+::.:-.:::==:::::=-               ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}               -: .=-      +......+               ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}             --::::=:     =:.......=.             ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}            +=::::::+=  .=  :-::--  -:            ${COLOR_NO}"
    Write-Host "${COLOR_LIGHT_GRAY}            +::=::=::+  +:::=::::=:::+:           ${COLOR_NO}"
    Write-Host "                        =::::::::::::=            "
}

function r2_commands_list
{
    Write-Host "+---------------------------------------------------------+"
    Write-Host "| R2 CLI - Command Line Interface                         |"
    Write-Host "+---------------------------------------------------------+"
    Write-Host "| r2 add <project-name>                                   |"
    Write-Host "| r2 run <project-name>                                   |"
    Write-Host "| r2 run argocd                                           |"
    Write-Host "| r2 restart <service-name>                               |"
    Write-Host "| r2 restart all                                          |"
    Write-Host "| r2 start <service-name>                                 |"
    Write-Host "| r2 stop <service-name>                                  |"
    Write-Host "| r2 stop all                                             |"
    Write-Host "| r2 setup <app-name>                                     |"
    Write-Host "| r2 delete all                                           |"
    Write-Host "| r2 ssh <service-name>                                   |"
    Write-Host "| r2 exec <service-name> <command>                        |"
    Write-Host "| r2 list                                                 |"
    Write-Host "| r2 update                                               |"
    Write-Host "| r2 d2 'Open AI chat...'                                 |"
    Write-Host "| r2 d2 sum <text>                                        |"
    Write-Host "| r2 help apps                                            |"
    Write-Host "+---------------------------------------------------------+"
    Write-Host "| r2 kube <command>                                       |"
    Write-Host "+---------------------------------------------------------+"
    Write-Host "| r2 release <project-name> <jira-project-code> <version> |"
    Write-Host "+---------------------------------------------------------+"
}

function r2_reload
{
    if (Test-Path $PROFILE) {
        . $PROFILE
    }
}

function r2_append_var
{
    param(
        [string]$v
    )
    $Env:PATH += ";" + $v
    [Environment]::SetEnvironmentVariable('PATH', $Env:PATH, [System.EnvironmentVariableTarget]::User)
    r2_reload
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

function r2_password
{
    param (
        [string]$prompt
    )
    $password = Read-Host -Prompt $prompt -AsSecureString
    $passwordPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    try {
        $passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPtr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPtr)
    }
    return $passwordPlain
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
    Write-Host "${COLOR_PURPLE}$message${COLOR_NO}"
}

function r2_msg_error
{
    param (
        [string]$message
    )
    Write-Host "${COLOR_RED}$message${COLOR_NO}"
}

switch ($command)
{
    "add" {
        git clone "$GIT_SYS_URL$arg1"
    }

    "kube" {
        switch ($arg1) {
            "start" {
                switch ($arg2) {
                    "tunnel" {
                        minikube tunnel
                    }
                    "ingress" {
                        minikube addons enable ingress
                    }
                    "argo" {
                        kubectl create namespace argocd
                        kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
                        kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
                        kubectl get pods -n argocd
                        Start-Process kubectl -ArgumentList "port-forward svc/argocd-server -n argocd 8080:443" -NoNewWindow
                        $pass = kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
                        argocd login localhost:8080 --insecure --username admin --password "$pass"
                        argocd cluster list
                    }
                    Default {
                        minikube start
                    }
                }
            }
            "list" {
                switch ($arg2) {
                    { $_ -eq "-s" -or $_ -eq "services" } {
                        r2_msg_info "Listing kube services..."
                        minikube kubectl -- get services
                    }
                    { $_ -eq "-n" -or $_ -eq "namespaces" } {
                        r2_msg_info "Listing kube services..."
                        minikube kubectl -- get namespaces
                    }
                    { $_ -eq "-p" -or $_ -eq "pods" } {
                        r2_msg_info "Listing kube services..."
                        minikube kubectl -- get pods -A
                    }
                    "all" {
                        r2_msg_info "Listing kube services..."
                        minikube kubectl -- get services
                        r2_msg_info "Listing kube namespaces..."
                        minikube kubectl -- get namespaces
                        r2_msg_info "Listing kube pods in all namespaces..."
                        minikube kubectl -- get pods --all-namespaces
                    }
                }
            }
            "ssh" {
                minikube kubectl -- exec --stdin --tty $arg2 -- /bin/bash
            }
            Default {
                # minikube kubectl -- $arg1 $arg2 $arg3 $arg4 $arg5 $arg6
                # Since we don't have direct access to all args easily in a switch like this, we'll try to reconstruct
                $kubeArgs = @($arg1, $arg2, $arg3, $arg4, $arg5, $arg6) | Where-Object { $_ }
                minikube kubectl -- $kubeArgs
            }
        }
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
            default {
                if (Test-Path -Path "$R2_WORKSPACE\$arg1") {
                    Set-Location "$R2_WORKSPACE\$arg1"
                    docker-compose down
                } else {
                    docker rm $(docker ps -aqf "name=^$arg1")
                }
            }
        }
    }

    "run" {

        if ($arg1 -eq "argocd") {
            kind create cluster --name argocd-demo
            kubectl create namespace argocd
            kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
            kubectl get pods -n argocd
            kubectl port-forward svc/argocd-server -n argocd 8080:443
            kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

            $confirm = r2_read "Do you want to login to ArgoCD thru CLI? [y/N]:"
            if ($confirm -eq "Y" -or $confirm -eq "y") {
                $argo_username = r2_read "Username:"
                $argo_password = r2_password "Password:"
                argocd login localhost:8080 --username $argo_username --password $argo_password --insecure
            }
        } elseif ($arg2) {
            Set-Location "$env:R2_WORKSPACE$arg1"
            docker-compose run $arg2
        } elseif (Test-Path "$env:R2_WORKSPACE$arg1") {
            Set-Location "$env:R2_WORKSPACE$arg1"
            docker-compose up --build
        } else {
            docker run $(docker ps -aqf "name=^$arg1")
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
                $result = $result -replace '^"', '' -replace '"$', ''
                $result = $result -replace '```python', "```python$COLOR_DARK_GREY"
                $result = $result -replace '```cpp', "```cpp$COLOR_RED"
                $result = $result -replace '```javascript', "```javascript$COLOR_BLUE"
                $result = $result -replace '```java', "```java$COLOR_LIGHT_RED"
                $result = $result -replace '```csharp', "```csharp$COLOR_GREEN"
                $result = $result -replace '```rust', "```rust$COLOR_LIGHT_GREEN"
                $result = $result -replace '```go', "```go$COLOR_BROWN_ORANGE"
                $result = $result -replace '```swift', "```swift$COLOR_YELLOW"
                $result = $result -replace '```typescript', "```typescript$COLOR_LIGHT_BLUE"
                $result = $result -replace '```kotlin', "```kotlin$COLOR_LIGHT_PURPLE"
                $result = $result -replace '```ruby', "```ruby$COLOR_CYAN"
                $result = $result -replace '```php', "```php$COLOR_LIGHT_CYAN"
                $result = $result -replace '```html', "```html$COLOR_LIGHT_GRAY"
                $result = $result -replace '```bash', "```bash$COLOR_PURPLE"
                $result = $result -replace '```', "$COLOR_NO```"
                Write-Host "$result$COLOR_NO"
            }
            default {
                $result = r2_openai_call "$arg1"
                $result = $result -replace '^"', '' -replace '"$', ''
                $result = $result -replace '```python', "```python$COLOR_DARK_GREY"
                $result = $result -replace '```cpp', "```cpp$COLOR_RED"
                $result = $result -replace '```javascript', "```javascript$COLOR_BLUE"
                $result = $result -replace '```java', "```java$COLOR_LIGHT_RED"
                $result = $result -replace '```csharp', "```csharp$COLOR_GREEN"
                $result = $result -replace '```rust', "```rust$COLOR_LIGHT_GREEN"
                $result = $result -replace '```go', "```go$COLOR_BROWN_ORANGE"
                $result = $result -replace '```swift', "```swift$COLOR_YELLOW"
                $result = $result -replace '```typescript', "```typescript$COLOR_LIGHT_BLUE"
                $result = $result -replace '```kotlin', "```kotlin$COLOR_LIGHT_PURPLE"
                $result = $result -replace '```ruby', "```ruby$COLOR_CYAN"
                $result = $result -replace '```php', "```php$COLOR_LIGHT_CYAN"
                $result = $result -replace '```html', "```html$COLOR_LIGHT_GRAY"
                $result = $result -replace '```bash', "```bash$COLOR_PURPLE"
                $result = $result -replace '```', "$COLOR_NO```"
                Write-Host "$result$COLOR_NO"
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

                r2_msg_info "Chocolatey is needed to install jq..."
                $confirm = r2_read "Have you installed chocolatey? [y/N]:"
                if ($confirm -eq "Y" -or $confirm -eq "y") {
                    choco install jq
                }
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

            "argocd" {
                choco install argocd-cli
            }

            "minikube" {
                choco install minikube
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
                r2_msg "r2 setup minikube"
                r2_msg "r2 setup argocd"
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