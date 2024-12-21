r2_read(){
  read -r -p "$1" set_read
  echo $set_read
}

confirm=$(r2_read "Are you sure you want to install R2 CLI [y/N]?")

if [ $confirm == "Y" ] || [ $confirm == "y" ]; then
  R2_WORKSPACE="$(pwd)/../"
  cp ./app.sh $R2_WORKSPACE/.r2.sh
  chmod +x $R2_WORKSPACE/.r2.sh

  if [ -f ~/.zshrc ];then
    echo "R2_WORKSPACE=$R2_WORKSPACE" >>~/.zshrc
    echo alias r2="$PWD/../.r2.sh" >>~/.zshrc

    source ~/.zshrc
  fi

  if [ -f ~/.bashrc ];then
    echo "R2_WORKSPACE=$R2_WORKSPACE" >>~/.bashrc
    echo alias r2="$PWD/../.r2.sh" >>~/.bashrc

    source ~/.bashrc
  fi
fi