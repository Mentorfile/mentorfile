#!/bin/bash
# Copies the fixture transcripts into the empty run workspace.
cp -R "$(cd "$(dirname "$0")" && pwd)/transcripts" ./transcripts
