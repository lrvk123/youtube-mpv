#! /bin/bash
set -ex

YMPV_DIR="$(readlink -f "$(dirname "$0")")"
VENV="${XDG_DATA_HOME:-$YMPV_DIR}/.youtube-mpv-venv"
CFGDIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"


# install dependencies
echo "You MUST have EPEL repository enabled for Python3 packages installation"
if ! (which pip3 && which virtualenv-3) > /dev/null; then
    sudo yum install -y python34-pip python34-virtualenv
fi
[[ -e "$VENV/bin/activate" ]] || virtualenv-3 "$VENV"
source "$VENV/bin/activate"
python3 -m youtube_dl --help &> /dev/null || pip3 install youtube_dl


# register as systemd service

mkdir -p "$CFGDIR"
cat > "$CFGDIR/youtube-mpv.service" <<EOF
[Unit]
Description=Python server which can play youtube links

[Service]
Type=simple
ExecStart=${VENV}/bin/python "${YMPV_DIR}/ytdl_server.py"

[Install]
WantedBy=default.target
EOF

# start the service

systemctl --user daemon-reload
systemctl --user restart youtube-mpv
systemctl --user enable youtube-mpv
