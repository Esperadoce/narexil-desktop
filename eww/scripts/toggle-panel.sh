#!/bin/bash
if eww active-windows | grep -q dashboard; then
  eww close dashboard
else
  eww open dashboard
fi
