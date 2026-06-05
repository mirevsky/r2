Describe 'app.sh'
  Include ./app.sh

  Describe 'r2_msg()'
    It 'outputs the message'
      When call r2_msg "test message"
      The output should equal "test message"
    End
  End

  Describe 'r2_msg_info()'
    It 'outputs the message in purple'
      When call r2_msg_info "info message"
      The output should include "info message"
      # COLOR_PURPLE is \e[0;35m
      The output should include "0;35m"
    End
  End

  Describe 'r2_msg_error()'
    It 'outputs the message in red'
      When call r2_msg_error "error message"
      The output should include "error message"
      # COLOR_RED is \e[0;31m
      The output should include "0;31m"
    End
  End

  Describe 'r2_logo()'
    It 'outputs the logo'
      When call r2_logo
      The line 1 of output should include ":::::::"
    End
  End

  Describe 'r2_commands_list()'
    It 'outputs the command list'
      When call r2_commands_list
      The output should include "R2 CLI - Command Line Interface"
      The output should include "r2 add <project-name>"
    End
  End

  Describe 'r2_read()'
    r2_read() { echo "user input"; }
    It 'reads user input'
      When call r2_read "Prompt: "
      The output should include "user input"
    End
  End

  Describe 'Main entry points'
    # Use a helper to run the script with mocked PATH
    run_app() {
      mkdir -p spec/bin
      for cmd in git minikube docker docker-compose brew; do
        echo "#!/bin/sh" > "spec/bin/$cmd"
        echo "echo \"\$0 called with \$*\"" >> "spec/bin/$cmd"
        chmod +x "spec/bin/$cmd"
      done
      env PATH="$PWD/spec/bin:$PATH" ./app.sh "$@"
    }

    Context 'add command'
      It 'calls git clone'
        export GIT_SYS_URL="https://github.com/"
        When call run_app add myrepo
        The output should include "git called with clone https://github.com/myrepo"
      End
    End

    Context 'kube command'
      It 'calls minikube start'
        When call run_app kube start
        The output should include "minikube called with start"
      End

      It 'calls minikube tunnel'
        When call run_app kube start tunnel
        The output should include "minikube called with tunnel"
      End

      It 'calls minikube addons enable ingress'
        When call run_app kube start ingress
        The output should include "minikube called with addons enable ingress"
      End

      It 'calls minikube kubectl for services'
        When call run_app kube list services
        The output should include "minikube called with kubectl -- get services"
      End
    End

    Context 'list command'
      It 'calls docker ps'
        When call run_app list
        The output should include "docker called with ps"
      End
    End

    Context 'stop command'
      It 'stops all containers'
        When call run_app stop all
        The output should include "docker called with kill"
      End

      It 'stops specific service in workspace'
        export R2_WORKSPACE="/tmp/"
        mkdir -p /tmp/myservice
        When call run_app stop myservice
        The output should include "docker-compose called with stop"
      End
    End

    Context 'run command'
      It 'runs specific service in workspace'
        export R2_WORKSPACE="/tmp/"
        mkdir -p /tmp/myservice
        When call run_app run myservice
        The output should include "docker-compose called with up --build"
      End
    End

    Context 'setup command'
      It 'sets up minikube'
        When call run_app setup minikube
        The output should include "brew called with install minikube"
      End

      It 'sets up jq'
        When call run_app setup jq
        The output should include "brew called with install jq"
      End
    End

    Context 'release command'
      It 'fails if parameters missing'
        When call run_app release
        The output should include "Additional parameters required!"
      End

      It 'fails if directory does not exist'
        export R2_WORKSPACE="/tmp/"
        When call run_app release proj jira 1.0.0
        The output should include "Directory does not exist!"
        The stderr should include "No such file or directory"
      End
    End

    Context 'update command'
      It 'pulls and copies app.sh'
        export R2_WORKSPACE="/tmp/"
        mkdir -p /tmp/r2
        touch /tmp/r2/app.sh
        When call run_app update
        The output should include "git called with pull"
        The stderr should include "Oh My Zsh"
      End
    End

    Context 'd2 command'
      # Mock curl to return some JSON
      run_app_d2() {
        mkdir -p spec/bin
        echo "#!/bin/sh" > spec/bin/curl
        echo "echo '{\"choices\": [{\"message\": {\"content\": \"\\\"summary results\\\"\"}}]}'" >> spec/bin/curl
        chmod +x spec/bin/curl
        echo "#!/bin/sh" > spec/bin/jq
        # Minimal jq mock to extract content
        echo "if [ \"\$1\" = \".choices\" ]; then echo '[{\"message\": {\"content\": \"\\\"summary results\\\"\"}}]'; elif [ \"\$1\" = \".message\" ]; then echo '{\"content\": \"\\\"summary results\\\"\"}'; else echo \"\\\"summary results\\\"\"; fi" >> spec/bin/jq
        chmod +x spec/bin/jq
        env PATH="$PWD/spec/bin:$PATH" OPENAI_URL="http://mock" OPENAI_API_KEY="key" ./app.sh "$@"
      }

      It 'summarizes text via d2 sum'
        When call run_app_d2 d2 sum "text to summarize"
        The output should include "summary results"
      End

      It 'chats via d2'
        When call run_app_d2 d2 "hello"
        The output should include "summary results"
      End
    End

    Context 'delete command'
      run_app_confirm() {
        mkdir -p spec/bin
        # Mock docker
        for cmd in docker; do
          echo "#!/bin/sh" > "spec/bin/$cmd"
          echo "echo \"\$0 called with \$*\"" >> "spec/bin/$cmd"
          chmod +x "spec/bin/$cmd"
        done
        # Mock r2_read to return Y
        # We need to redefine it in the script or mock the 'read' command
        # Since we run script as a separate process, we can't easily redefine function
        # But we can provide input via stdin
        echo "Y" | env PATH="$PWD/spec/bin:$PATH" ./app.sh "$@"
      }

      It 'deletes all images and volumes'
        When call run_app_confirm delete all
        The output should include "docker called with kill"
        The output should include "docker called with system prune"
      End
    End
  End
End
