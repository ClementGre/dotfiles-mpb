#!/bin/bash

sudo route delete sslvpn.cisr.fr
sudo security find-generic-password -w -s PlaneteInsaVpn | sudo /run/current-system/sw/bin/openconnect sslvpn.cisr.fr \
  --protocol=anyconnect \
  -u cgrennerat@insa-lyon.fr \
  --authgroup=INSA \
  --passwd-on-stdin \
  -s '/run/current-system/sw/bin/vpn-slice bde608-d07.insa-lyon.fr 134.214.129.48 134.214.129.0/26 insa-lyon.fr login.insa-lyon.fr intranet.insa-lyon.fr intranetfimi.insa-lyon.fr partage.insa-lyon.fr planete.insa-lyon.fr bv.insa-lyon.fr inria-abita.insa-lyon.fr gespage.insa-lyon.fr inkk-hebergement.insa-lyon.fr menu-restaurants.insa-lyon.fr fimi-bd-srv1.insa-lyon.fr imp-cervoprint.insa-lyon.fr 134.214.182.106 bde608-s05.insa-lyon.fr bde608-s01.insa-lyon.fr equipes.bde.insa-lyon.fr intranethumas.insa-lyon.fr paiement.insa-lyon.fr if-dbora-01.insa-lyon.fr helpdesk.insa-lyon.fr ps-home.insa-lyon.fr ps-partages.insa-lyon.fr ddl.insa-lyon.fr' \
  --background

bash "$CONFIG_DIR/plugins/vpn_insa.sh"
