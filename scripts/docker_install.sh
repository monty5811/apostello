set -e

apt-get update -y
apt-get install -y python3-virtualenv
python3 -m venv venv
. venv/bin/activate
pip install apostello-cli
apostello init
cd apostello
apostello build

echo "################################################################"
echo "## apostello is now ready for configuration                   ##"
echo "##                                                            ##"
echo "## Please run "apostello config" and follow the prompts       ##"
echo "##                                                            ##"
echo "## Then run                                                   ##"
echo "##         apostello build                                    ##"
echo "##         apostello start                                    ##"
echo "##         apostello migrate                                  ##"
echo "##                                                            ##"
echo "## To upgrade run "apostello upgrade"                         ##"
echo "##                                                            ##"
echo "################################################################"
