#!/bin/bash

packer build \
  --only=vmware-iso \
  --var vhv_enable=true \
  --var iso_url=~/downloads/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso \
  windows_2019.json
