#!/bin/bash
# Insider ISO
packer build \
  --only=virtualbox-iso \
  --var vhv_enable=true \
  --var autounattend=./answer_files/2019_core/Autounattend.xml \
  --var iso_url=~/Downloads/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso  windows_2019_core_kubernetes.json
