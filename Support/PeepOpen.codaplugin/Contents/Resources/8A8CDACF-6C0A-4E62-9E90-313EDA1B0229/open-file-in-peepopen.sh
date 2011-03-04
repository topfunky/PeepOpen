#!/bin/sh

if (set -u; : $CODA_SITE_LOCAL_PATH) 2> /dev/null
then
  open "peepopen://$CODA_SITE_LOCAL_PATH?editor=Coda"
fi

