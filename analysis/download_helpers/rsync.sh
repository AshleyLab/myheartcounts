#!/bin/sh
rsync -arvR --size-only --files-from synapseCache.tocopy2 annashch@masamune:/home/common/myheart/data/synapseCache /scratch/PI/euan/projects/mhc/data/synapseCache/

