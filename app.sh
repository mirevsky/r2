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
r2_commands_list(){
  echo -e "+---------------------------------------------------------+";
  echo -e "| R2 CLI - Command Line Interface                         |";
  echo -e "+---------------------------------------------------------+";
  echo -e "| r2 add <project-name>                                   |";
  echo -e "| r2 run <project-name>                                   |";
  echo -e "| r2 start <service-name>                                 |";
  echo -e "| r2 stop <service-name>                                  |";
  echo -e "| r2 stop all                                             |";
  echo -e "| r2 setup <app-name>  (git | jira | openai)              |";
  echo -e "| r2 delete all                                           |";
  echo -e "| r2 ssh <service-name>                                   |";
  echo -e "| r2 list                                                 |";
  echo -e "| r2 update                                               |";
  echo -e "| r2 d2 'Open AI chat...'                                 |";
  echo -e "| r2 d2 sum <text>                                        |";
  echo -e "+---------------------------------------------------------+";
  echo -e "| r2 release <project-name> <jira-project-code> <version> |";
  echo -e "+---------------------------------------------------------+";
}

r2_reload(){
  if [ -f ~/.zshrc ];then
    source ~/.zshrc
  fi

  if [ -f ~/.bashrc ];then
    source ~/.bashrc
  fi
}

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

r2_openai_call(){
  data=$1
  template='{ "model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "%s"}], "temperature": 0.7}'
  result=$(curl -s "$OPENAI_URL/v1/chat/completions" -H "Content-Type: application/json" -H "Authorization: Bearer $OPENAI_API_KEY" -d "$(printf "$template" "$data")" )
  echo $result
}

r2_jira_call(){
  type=$1
  url=$2
  data=$3
  result=$(curl -s -X $type "$JIRA_SYS_URL$url" --user "$JIRA_SYS_EMAIL:$JIRA_API_KEY" -H "Accept: application/json" -H "Content-Type: application/json" -d "$data")
  echo $result
}

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

  result=$(r2_jira_call POST "rest/api/2/issue" "$(printf "$template" "$project" "$summary" "$description" "$issuetype")")
  echo $result | jq ".key"
}

r2_jira_get_description(){
  pr=$1
  description=$(r2_jira_call GET "rest/api/2/issue/$pr?fields=description")
  echo $description | jq '.fields' | jq '.description'
}

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
  r2_jira_call POST "rest/api/2/issue/$ticket" "$(printf "$template" "$tag")"
}

r2_jira_move_ticket(){
  ticket=$1
  transition=$2
  template='{"transition":{"id":%s}}'
  r2_jira_call POST "rest/api/3/issue/$ticket/transitions" "$(printf "$template" "$transition")"
}

r2_read(){
  read -r -p "$1" set_read
  echo $set_read
}

r2_msg(){
  echo -e "$1"
}

r2_msg_info(){
  echo -e "${COLOR_PURPLE}$1${COLOR_NO}"
}

r2_msg_error(){
  echo -e "${COLOR_RED}$1${COLOR_NO}"
}

case $1 in
  add)
    git clone "$GIT_SYS_URL$2"
    ;;

  release)
      if [ -z $3 ] || [ -z $4 ] || [ -z $5 ];then
          r2_msg_error "Additional parameters required!"
          exit
      fi

      project_name=$3
      project_jira_code=$4
      version=$5

      if [ ! -d $R2_WORKSPACE/$3 ];then
        r2_msg_error "Directory does not exist!"
      fi

      cd $R2_WORKSPACE/$3

      git fetch --all --quiet

      exists=`git show-ref refs/heads/$version`
      if [ -n "$exists" ]; then
          git checkout $version
          git pull
      else
        r2_msg_error "Release version $version does not exist!"
        exit
      fi

      main_branch='main'
      exists=`git show-ref refs/heads/main`
      if [ -n "$exists" ]; then
          git checkout main
          git pull
      fi

      exists=`git show-ref refs/heads/master`
      if [ -n "$exists" ]; then
          main_branch='master'
          git checkout master
          git pull
      fi

      list_branches=$(git log $version...$main_branch | egrep "^(?i)($project_jira_code)[- 0-9](?-i).*" )

      description=$(r2_read "Enter description for the release:")

      r2_jira_create_release $project_jira_code $version $description

      for pr in list_branches[@]; do
        r2_jira_tag_release $pr $version
        jira_prs+='{"type": "inlineCard","attrs":{"url":"'$JIRA_SYS_URL'/browse/'$pr'"}},'
        description_data=$(r2_jira_get_description $pr)
        jira_description+="$description_data"
      done

      confirm=$(r2_read "Do you want to create release ticket [y/N]?")

      template_description='[
      {"type": "paragraph","content": [{"type": "text","text": "Comment: %s"}]},
      {"type": "paragraph", "content": [ %s ]}]'

      if [ $confirm == "Y" ] || [ $confirm == "y" ];then
        project_jira_code=$(r2_read "Set JIRA project code:")
        r2_jira_create_ticket $project_jira_code Story "Release-$version" "$(printf "$template_description" "$version" "$jira_prs")"
      fi

      confirm=$(r2_read "Do you want to create release pull request [y/N]?")
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
    if [ -d "$R2_WORKSPACE/$2" ]; then
      cd "$R2_WORKSPACE/$2"
      docker-compose run "$3"
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
        if [ -d "$R2_WORKSPACE/$2" ]; then
          cd "$R2_WORKSPACE/$2"
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
        if [ -d "$R2_WORKSPACE/$2" ]; then
          cd "$R2_WORKSPACE/$2"
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
    if [ -d "$R2_WORKSPACE/r2" ]; then
      cd $R2_WORKSPACE
      git pull
      cp app.sh $R2_WORKSPACE/../.r2.sh
      r2_reload
    fi
    ;;

  d2)
    case $1 in
      sum)
        result=$(r2_openai_call "Summarize the following text: $2")
        echo $result
        ;;
      *)
        result=$(r2_openai_call "$2")
        echo $result
        ;;
    esac
    ;;

  setup)
    case $2 in
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
      r2 setup homebrew
      confirm=$(r2_read "Have you installed homebrew? [y/N]:")
      if [ "$confirm" == "Y" ] || [ "$confirm" = "y" ]; then
        r2 setup jq
      fi
      ;;

    openai)
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
       ;;
     *)
       r2_logo
       r2_commands_list
       ;;
    esac
    ;;
esac
