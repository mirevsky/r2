#!/bin/bash

TEXT_BOLD="\e[1m"
TEXT_UNDERLINE="\e[4m"
TEXT_NORMAL="\e[0m"

COLOR_BLACK="\e[0;30m"
COLOR_DARK_GREY="\e[1;30m"
COLOR_RED="\e[0;31m"
COLOR_LIGHT_RED="\e[1;31m"
COLOR_GREEN="\e[0;32m"
COLOR_LIGHT_GREEN="\e[1;32m"
COLOR_BROWN_ORANGE="\e[0;33m"
COLOR_YELLOW="\e[1;33m"
COLOR_BLUE="\e[0;34m"
COLOR_LIGHT_BLUE="\e[1;34m"
COLOR_PURPLE="\e[0;35m"
COLOR_LIGHT_PURPLE="\e[1;35m"
COLOR_CYAN="\e[0;36m"
COLOR_LIGHT_CYAN="\e[1;36m"
COLOR_LIGHT_GRAY="\e[0;37m"
COLOR_WHITE="\e[1;37m"
COLOR_NO="\e[0m" # No Color

# Renders the R2 CLI logo to the terminal
r2_logo() {
  echo -e "${COLOR_LIGHT_GRAY}                       .--${COLOR_LIGHT_BLUE}:::::::${COLOR_LIGHT_GRAY}.                ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}                     --${COLOR_LIGHT_BLUE}..::::.${COLOR_LIGHT_GRAY}   :-:              ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}                    =.       ${COLOR_LIGHT_BLUE}.::::.:${COLOR_LIGHT_GRAY}=             ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}                   =${COLOR_LIGHT_BLUE}:::=-:-       ${COLOR_LIGHT_GRAY}.:-=            ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}                  =-::-= .${COLOR_LIGHT_BLUE}+::=:::.   ${COLOR_LIGHT_GRAY}=.           ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}                 :-    .:=-:+.   .*  =            ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}                .=     --::-+=:::${COLOR_LIGHT_BLUE}=::${COLOR_LIGHT_GRAY}==            ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}                +     + .-:: =.  .:-+             ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}               =.     + :-:=  =    =              ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}              -:     .*.      =.  -.              ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}             :-      +.=      -: :-               ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}            .=      =. :-::::-= .=                ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}            +  ${COLOR_LIGHT_BLUE}:--:${COLOR_LIGHT_GRAY}=-   :*.   + +                 ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}           :=::+   =-${COLOR_LIGHT_BLUE}:::${COLOR_LIGHT_GRAY}=.=   :+.                 ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}           .=  .::=+.     =.   +.                 ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}            .::::.  .::::.==::::--                ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}                =:::::.  .+      +                ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}               .+::.:-.:::==:::::=-               ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}               -: .=-      +......+               ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}             --::::=:     =:.......=.             ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}            +=::::::+=  .=  :-::--  -:            ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}            +::=::=::+  +:::=::::=:::+:           ${COLOR_NO}";
  echo -e "${COLOR_LIGHT_GRAY}                        =::::::::::::=            ${COLOR_NO}";
}
# Displays a list of available R2 CLI commands
r2_commands_list(){
  echo -e "+---------------------------------------------------------+";
  echo -e "| R2 CLI - Command Line Interface                         |";
  echo -e "+---------------------------------------------------------+";
  echo -e "| r2 add <project-name>                                   |";
  echo -e "| r2 run <project-name>                                   |";
  echo -e "| r2 run argocd                                           |";
  echo -e "| r2 restart <service-name>                               |";
  echo -e "| r2 restart all                                          |";
  echo -e "| r2 start <service-name>                                 |";
  echo -e "| r2 stop <service-name>                                  |";
  echo -e "| r2 stop all                                             |";
  echo -e "| r2 setup <app-name>                                     |";
  echo -e "| r2 delete all                                           |";
  echo -e "| r2 ssh <service-name>                                   |";
  echo -e "| r2 exec <service-name> <command>                        |";
  echo -e "| r2 list                                                 |";
  echo -e "| r2 update                                               |";
  echo -e "| r2 d2 'Open AI chat...'                                 |";
  echo -e "| r2 d2 sum <text>                                        |";
  echo -e "| r2 help apps                                            |";
  echo -e "+---------------------------------------------------------+";
  echo -e "| r2 kube <command>                                       |";
  echo -e "+---------------------------------------------------------+";
  echo -e "| r2 release <project-name> <jira-project-code> <version> |";
  echo -e "+---------------------------------------------------------+";
}

# Reloads the user's shell configuration (zsh or bash)
r2_reload(){
  if [ -f ~/.zshrc ];then
    source ~/.zshrc
  fi

  if [ -f ~/.bashrc ];then
    source ~/.bashrc
  fi
}

# Appends an export variable statement to the shell configuration files and reloads them
# @param $1 The variable assignment string (e.g., "VAR=value")
r2_append_var(){
  v=$1
  if [ -f ~/.zshrc ];then
    echo "export $v" >> ~/.zshrc
  fi

  if [ -f ~/.bashrc ];then
    echo "export $v" >> ~/.bashrc
  fi
  r2_reload
}

# Sends a prompt to the OpenAI API and echoes the response content
# @param $1 The prompt text to send to OpenAI
r2_openai_call(){
  data=$1
  if [ -n "$data" ];then
    payload=$(jq -n \
      --arg model "gpt-4.1" \
      --arg content "$data" \
      '{
        model: $model,
        messages: [
          {
            role: "user",
            content: $content
          }
        ],
        temperature: 0.7
      }')

    result=$(curl -s "$OPENAI_URL/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d "$payload")
    echo "$result" | jq -r '.choices[].message.content'
  fi
}

# Performs a generic REST API call to Jira
# @param $1 The HTTP method (GET, POST, PUT, etc.)
# @param $2 The API endpoint path
# @param $3 The JSON data payload for the request
r2_jira_call(){
  type=$1
  url=$2
  data=$3
  result=$(curl -s -X $type "$JIRA_SYS_URL$url" --user "$JIRA_SYS_EMAIL:$JIRA_API_KEY" -H "Accept: application/json" -H "Content-Type: application/json" -d "$data")
  echo $result
}

# Creates a new ticket in Jira
# @param $1 Jira project key
# @param $2 Issue type (e.g., Story, Bug)
# @param $3 Summary of the issue
# @param $4 Description content in Jira Document Format (JSON string)
r2_jira_create_ticket(){
  project=$1
  issuetype=$2
  summary=$3
  description=$4
  template='
  {
  "fields": {
     "project":
     {
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
  }'
  result=$(r2_jira_call POST "rest/api/3/issue" "$(printf "$template" "$project" "$summary" "$description" "$issuetype")")
  echo $result | jq ".key"
}

# Fetches the description of a specific Jira issue
# @param $1 Jira issue key (ticket ID)
r2_jira_get_description(){
  pr=$1
  description=$(r2_jira_call GET "rest/api/2/issue/$pr?fields=description")
  echo $description | jq '.fields' | jq '.description'
}

# Creates a new release version in Jira
# @param $1 Jira project key
# @param $2 Release name (version)
# @param $3 Release description
r2_jira_create_release(){
  project=$1
  name=$2
  description=$3

  template='{
   "archived": false,
   "description": "%s",
   "name": "%s",
   "project": "%s",
   "releaseDate": "%s",
   "released": false
  }'
  r2_jira_call POST "rest/api/3/version" "$(printf "$template" "$description" "$name" "$project" "$(date +"%Y-%m-%d")")"
}

# Adds a fix version tag to a specific Jira issue
# @param $1 Jira issue key
# @param $2 Version name to tag the issue with
r2_jira_tag_release(){
  ticket=$1
  tag=$2
  template='{
    "update": {
      "fixVersions": [{
          "add": {"name": "%s"}
        }
      ]
    }
  }'
  r2_jira_call PUT "rest/api/2/issue/$ticket" "$(printf "$template" "$tag")"
}

# Transitions a Jira ticket to a new status
# @param $1 Jira issue key
# @param $2 Transition ID
r2_jira_move_ticket(){
  ticket=$1
  transition=$2
  template='{"transition":{"id":%s}}'
  r2_jira_call POST "rest/api/3/issue/$ticket/transitions" "$(printf "$template" "$transition")"
}

# Reads user input from the terminal with a prompt
# @param $1 The prompt message to display
r2_read(){
  read -r -p "$1" set_read
  echo $set_read
}

# Reads sensitive user input (password) from the terminal without echoing
# @param $1 The prompt message to display
r2_password() {
  read -r -s -p "$1" password
  echo "$password"
}

# Echoes a message to the terminal
# @param $1 The message to display
r2_msg(){
  echo "$1"
}

# Echoes an informational message in purple color
# @param $1 The message to display
r2_msg_info(){
  echo -e "${COLOR_PURPLE}$1${COLOR_NO}"
}

# Echoes an error message in red color
# @param $1 The message to display
r2_msg_error(){
  echo -e "${COLOR_RED}$1${COLOR_NO}"
}

case $1 in
  add)
    git clone "$GIT_SYS_URL$2"
    ;;

  kube)
    case $2 in
      start)
        case $3 in
          tunnel)
            minikube tunnel
          ;;
          ingress)
            minikube addons enable ingress
            ;;
          argo)
            # Create the argocd namespace
            kubectl create namespace argocd

            # Install ArgoCD using the official manifest
            kubectl apply -n argocd --server-side --force-conflicts \
              -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

            # Wait for all ArgoCD pods to be ready
            kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

            # Check all ArgoCD pods
            kubectl get pods -n argocd

            # Port-forward the ArgoCD server to localhost
            kubectl port-forward svc/argocd-server -n argocd 8080:443 &

            # Now access ArgoCD at https://localhost:8080
            # Your browser will show a certificate warning - this is expected
            # Retrieve the admin password
            pass=$(kubectl get secret argocd-initial-admin-secret -n argocd \
              -o jsonpath='{.data.password}' | base64 -d && echo)

            # Login via CLI (accept the self-signed cert with --insecure)
            argocd login localhost:8080 --insecure --username admin --password "$pass"

            # Verify the connection
            argocd cluster list
            # Should show the in-cluster connection

            ;;
          *)
            minikube start
            ;;
        esac
        ;;
      list)
        case $3 in
          -s | services)
            r2_msg_info "Listing kube services..."
            minikube kubectl -- get services
          ;;
          -n | namespaces)
            r2_msg_info "Listing kube services..."
            minikube kubectl -- get namespaces
          ;;
          -p | pods)
            r2_msg_info "Listing kube services..."
            minikube kubectl -- get pods -A
          ;;
          all)
            r2_msg_info "Listing kube services..."
            minikube kubectl -- get services
            r2_msg_info "Listing kube namespaces..."
            minikube kubectl -- get namespaces
            r2_msg_info "Listing kube pods in all namespaces..."
            minikube kubectl -- get pods --all-namespaces
            ;;
        esac
        ;;
      ssh)
        minikube kubectl -- exec --stdin --tty $3 -- /bin/bash
        ;;
      *)
        minikube kubectl -- $2 $3 $4 $5 $6 $7 $8 $9
        ;;
    esac
    ;;

  release)
      if [ -z $2 ] || [ -z $3 ] || [ -z $4 ];then
          r2_msg_error "Additional parameters required!"
          exit
      fi

      project_name=$2
      project_jira_code=$3
      version=$4

      if [ -n "$5" ] && [ "$5" == "--non-interactive" ];then
          if [ -f ~/.r2_config ];then
            R2_CONFIRM_RELEASE_TICKET='Y'
            R2_RELEASE_CONFIRM=''
            R2_MOVE_JIRA_TICKET=''
            source ~/.r2_config
          else
            r2_msg_error "File ~/.r2_config does not exist!"
            exit
          fi
      fi

      if [ ! -d $R2_WORKSPACE$2 ];then
        r2_msg_error "Directory does not exist!"
      fi

      cd $R2_WORKSPACE$2

      git fetch --all --quiet

      exists=$(git show-ref refs/heads/$version)
      if [ -n "$exists" ]; then
          git checkout $version
          git pull
      else
        r2_msg_error "Release version $version does not exist!"
        exit
      fi

      main_branch='main'
      exists=$(git show-ref refs/heads/main)
      if [ -n "$exists" ]; then
          git checkout main
          git pull
      fi

      exists=$(git show-ref refs/heads/master)
      if [ -n "$exists" ]; then
          main_branch='master'
          git checkout master
          git pull
      fi

      git checkout $version

      list_branches=$(git log $version...$main_branch --decorate="full" | egrep -o "($project_jira_code)[- 0-9]*" )

      if [ -n "$R2_DESCRIPTION" ];then
        description=$R2_DESCRIPTION
      else
        description=$(r2_read "Enter description for the release:")
      fi
      r2_jira_create_release $project_jira_code $version $description

      for pr in $list_branches; do
        r2_jira_tag_release $pr $version
        jira_prs+='{"type": "inlineCard","attrs":{"url":"'$JIRA_SYS_URL'browse/'$pr'"}},'
        description_data=$(r2_jira_get_description $pr)
        jira_description+="$description_data"
      done

      jira_prs=${jira_prs%,}
      if [ "$R2_CONFIRM_RELEASE_TICKET" == "Y" ];then
        confirm=$R2_CONFIRM_RELEASE_TICKET
      else
        confirm=$(r2_read "Do you want to create release ticket [y/N]?")
      fi

      template_description='[
      {"type": "paragraph","content": [{"type": "text","text": "Summary: %s"}]},
      {"type": "paragraph", "content": [ %s ]}
      ]'

      if [ $confirm == "Y" ] || [ $confirm == "y" ];then
        if [ -n "$R2_PROJECT_JIRA_CODE" ];then
          project_jira_code=$R2_PROJECT_JIRA_CODE
        else
          project_jira_code=$(r2_read "Set JIRA project code:")
        fi

        prompt=$(printf 'Summarize the following text:%s' "$jira_description")
        prompt=${prompt//\"/}

        template='{ "model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "%s"}], "temperature": 0.7}'
        if [ -n "$prompt" ];then
          openai_summary=$(curl -s "$OPENAI_URL/v1/chat/completions" -H "Content-Type: application/json" -H "Authorization: Bearer $OPENAI_API_KEY" -d "$(printf "$template" "$prompt")" )
          openai_summary=$(echo $openai_summary | jq ".choices" | jq '.[]' | jq ".message" | jq ".content")
          openai_summary=${openai_summary//\"/}
        fi
        result=$(r2_jira_create_ticket $project_jira_code Story "Release-$version" "$(printf "$template_description" "$openai_summary" "$jira_prs")")
        result=${result//\"/}
        echo "${JIRA_SYS_URL}browse/$result"

        if [ "$R2_MOVE_JIRA_TICKET" == "Y" ];then
          move_jira_ticket=$R2_MOVE_JIRA_TICKET
        else
          move_jira_ticket=$(r2_read "Do you want to move the ticket from the backlog [y/N]?")
        fi
        if [ $move_jira_ticket == "Y" ] || [ $move_jira_ticket == "y" ];then
          if [ -n "$R2_POSITION" ];then
            position=$R2_POSITION
          else
            position=$(r2_read "Specify the status value[number]:")
          fi
          r2_jira_move_ticket $result $position
        fi
      fi

      if [ -n "$R2_RELEASE_CONFIRM" ];then
        confirm=$R2_RELEASE_CONFIRM
      else
        confirm=$(r2_read "Do you want to create release pull request [y/N]?")
      fi
      if [ $confirm == "Y" ] || [ $confirm == "y" ];then
        git pull refs/heads/$version
        git commit -m "$version"
        git push
      fi
      ;;

  delete)
    case $2 in
      all)
        r2_msg "IMPORTANT: This action will prune all images and volumes!"
        confirm=$(r2_read "Are you sure you want to clear your services? [y/N]:")

        if [ "$confirm" == "Y" ] || [ "$confirm" == "y" ]; then
          docker kill $(docker ps -q)
          docker system prune
          docker system prune --volumes
          docker rmi $(docker images -a -q)
          r2_msg_info "All containers have been completely removed..."
          docker ps
          r2_msg_info "Run r2 run <project-name>"
        fi
        ;;
      esac
    ;;

  run)

    if [ "$2" == "argocd" ]; then
      kind create cluster --name argocd-demo
      # Create a namespace for ArgoCD resources
      kubectl create namespace argocd
      # Deploy ArgoCD using the official manifests
      kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
      # Check that ArgoCD pods are running
      kubectl get pods -n argocd
      # Forward ArgoCD server port to your local machine
      kubectl port-forward svc/argocd-server -n argocd 8080:443
      # Retrieve the initial admin password (stored as a secret)
      kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

      confirm=$(r2_read "Do you want to login to ArgoCD thru CLI? [y/N]:")
      if [ "$confirm" == "Y" ] || [ "$confirm" = "y" ]; then
        argo_username=$(r2_read "Username:")
        argo_password=$(r2_password "Password:")
        # Login to the ArgoCD server locally
        argocd login localhost:8080 --username $argo_username --password $argo_password --insecure
      fi

    elif [ -d "$R2_WORKSPACE$2" ] && [ -n "$3" ]; then
      cd "$R2_WORKSPACE$2"
      docker-compose run "$3"
    elif [ -d "$R2_WORKSPACE$2" ]; then
        cd "$R2_WORKSPACE$2"
        docker-compose up --build
    else
      docker run $(docker ps -aqf "name=^$2")
    fi
    ;;

  restart)
    case $2 in
      all)
        docker restart $(docker ps -q)
        ;;
      *)
        if [ -d "$R2_WORKSPACE$2" ]; then
          cd "$R2_WORKSPACE$2"
          docker-compose restart "$3"
        else
          docker restart $(docker ps -aqf "name=^$2")
        fi
        ;;
      esac
    ;;

  ssh)
    docker exec -it $(docker ps -aqf "name=^$2") /bin/bash
    ;;

  exec)
    docker exec -it $(docker ps -aqf "name=^$2") /bin/bash -c "$3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ${20}"
    ;;

  stop)
    case $2 in
      all)
        docker kill $(docker ps -q)
        ;;
      *)
        if [ -d "$R2_WORKSPACE$2" ]; then
          cd "$R2_WORKSPACE$2"
          docker-compose stop "$3"
        else
          docker kill $(docker ps -aqf "name=^$2")
        fi
        ;;
      esac
    ;;
  list)
    docker ps
    ;;
  update)
    if [ -d $R2_WORKSPACE"r2" ]; then
      cd $R2_WORKSPACE"r2"
      git pull
      cp app.sh $R2_WORKSPACE"r2/app.sh"
      r2_reload
    fi
    ;;

  d2)
    case $1 in
      sum)
        result=$(r2_openai_call "Summarize the following text: $2")
        result=${result#\"}
        result=${result%\"}
        result=${result//\`\`\`python/\`\`\`python${COLOR_DARK_GREY}}
        result=${result//\`\`\`cpp/\`\`\`cpp${COLOR_RED}}
        result=${result//\`\`\`javascript/\`\`\`javascript${COLOR_BLUE}}
        result=${result//\`\`\`java/\`\`\`java${COLOR_LIGHT_RED}}
        result=${result//\`\`\`csharp/\`\`\`csharp${COLOR_GREEN}}
        result=${result//\`\`\`rust/\`\`\`rust${COLOR_LIGHT_GREEN}}
        result=${result//\`\`\`go/\`\`\`go${COLOR_BROWN_ORANGE}}
        result=${result//\`\`\`swift/\`\`\`swift${COLOR_YELLOW}}
        result=${result//\`\`\`typescript/\`\`\`typescript${COLOR_LIGHT_BLUE}}
        result=${result//\`\`\`kotlin/\`\`\`kotlin${COLOR_LIGHT_PURPLE}}
        result=${result//\`\`\`ruby/\`\`\`ruby${COLOR_CYAN}}
        result=${result//\`\`\`php/\`\`\`php${COLOR_LIGHT_CYAN}}
        result=${result//\`\`\`html/\`\`\`html${COLOR_LIGHT_GRAY}}
        result=${result//\`\`\`bash/\`\`\`bash${COLOR_PURPLE}}
        result=${result//\`\`\`/${COLOR_NO}\`\`\`}
        echo -e $result
        ;;
      *)
        result=$(r2_openai_call "$2")
        result=${result#\"}
        result=${result%\"}
        result=${result//\`\`\`python/\`\`\`python${COLOR_DARK_GREY}}
        result=${result//\`\`\`cpp/\`\`\`cpp${COLOR_RED}}
        result=${result//\`\`\`javascript/\`\`\`javascript${COLOR_BLUE}}
        result=${result//\`\`\`java/\`\`\`java${COLOR_LIGHT_RED}}
        result=${result//\`\`\`csharp/\`\`\`csharp${COLOR_GREEN}}
        result=${result//\`\`\`rust/\`\`\`rust${COLOR_LIGHT_GREEN}}
        result=${result//\`\`\`go/\`\`\`go${COLOR_BROWN_ORANGE}}
        result=${result//\`\`\`swift/\`\`\`swift${COLOR_YELLOW}}
        result=${result//\`\`\`typescript/\`\`\`typescript${COLOR_LIGHT_BLUE}}
        result=${result//\`\`\`kotlin/\`\`\`kotlin${COLOR_LIGHT_PURPLE}}
        result=${result//\`\`\`ruby/\`\`\`ruby${COLOR_CYAN}}
        result=${result//\`\`\`php/\`\`\`php${COLOR_LIGHT_CYAN}}
        result=${result//\`\`\`html/\`\`\`html${COLOR_LIGHT_GRAY}}
        result=${result//\`\`\`bash/\`\`\`bash${COLOR_PURPLE}}
        result=${result//\`\`\`/${COLOR_NO}\`\`\`}
        echo -e $result
        ;;
    esac
    ;;

  setup)
    case $2 in
    argocd)
      brew install argocd
      ;;
    minikube)
      brew install minikube
      ;;

    git)
      confirm=$(r2_read "Do you want to generate ssh key? [y/N]:")
      if [ "$confirm" == "Y" ] || [ "$confirm" = "y" ]; then
        ssh_type=$(r2_read "Select type[ed25519,rsa]:")
        ssh_email=$(r2_read "Set user email:")
        ssh-keygen -t $ssh_type -C "$ssh_email"
        r2_msg "SSH key was generated! Pleas copy/paste the key bellow and add into your Github Account."
        eval "cat ~/.ssh/id_$ssh_type.pub"
      fi

      GIT_SYS_URL=$(r2_read "GIT Url:")
      r2_append_var "GIT_SYS_URL=$GIT_SYS_URL"
      ;;

    jira)
      JIRA_SYS_URL=$(r2_read "JIRA Url:")
      JIRA_SYS_EMAIL=$(r2_read "JIRA User email:")
      JIRA_API_KEY=$(r2_read "JIRA API Key:")
      r2_append_var "JIRA_SYS_URL=$JIRA_SYS_URL"
      r2_append_var "JIRA_SYS_EMAIL=$JIRA_SYS_EMAIL"
      r2_append_var "JIRA_API_KEY=$JIRA_API_KEY"

      r2_msg_info "Homebrew is needed..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      confirm=$(r2_read "Have you installed homebrew? [y/N]:")
      if [ "$confirm" == "Y" ] || [ "$confirm" = "y" ]; then
        brew install jq
      fi
      ;;

    openai)
      r2_msg_info "Note:OpenAI default url is https://api.openai.com"
      OPENAI_URL=$(r2_read "OpenAI URL:")
      OPENAI_API_KEY=$(r2_read "OpenAI API Key:")
      r2_append_var "OPENAI_URL=$OPENAI_URL"
      r2_append_var "OPENAI_API_KEY=$OPENAI_API_KEY"
      ;;

    nvm)
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
      confirm=$(r2_read "Did you updated the NVM environment variable? [y/N]:")
      if [ "$confirm" == "Y" ] || [ "$confirm" = "y" ]; then
        r2_reload
      fi
      ;;

    pyenv)
      curl https://pyenv.run | bash
      confirm=$(r2_read "Did you updated the PYENV environment variable? [y/N]:")
      if [ "$confirm" == "Y" ] || [ "$confirm" = "y" ]; then
        r2_reload
      fi
      ;;

    homebrew)
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      ;;

    go)
      brew install go
      ;;

    devtools)
      brew install --cask pycharm
      brew install --cask intellij-idea-ce
      brew install --cask beekeeper-studio
      brew install --cask postman
      brew install docker-compose
      ;;

    social)
      brew install --cask signal
      brew install --cask telegram
      brew install --cask vivaldi
      brew install --cask mailspring
      ;;

    jq)
      brew install jq
      ;;

    esac
    ;;
  help)
    case $2 in
     apps)
       r2_logo
       r2_msg "r2 setup nvm"
       r2_msg "r2 setup pyenv"
       r2_msg "r2 setup homebrew"
       r2_msg "r2 setup go"
       r2_msg "r2 setup openai"
       r2_msg "r2 setup jira"
       r2_msg "r2 setup jq"
       r2_msg "r2 setup minikube"
       r2_msg "r2 setup argocd"
       r2_msg "r2 setup devtools"
       r2_msg "r2 setup social"
       ;;
     *)
       r2_logo
       r2_commands_list
       ;;
    esac
    ;;
esac
