mkdir -p /home/cw/work
eval "$(pyenv init -) && $(pyenv virtualenv-init -)"
cd /home/cw/chipwhisperer/jupyter
pyenv activate cw
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token='' --NotebookApp.password=''
#/bin/bash