# Heimdall2 For Rancher

This is a fork of https://github.com/mitre/heimdall2

## Changes from Upstream

1. In various locations, define base paths/urls. This is necessary so as to serve Heimdall2 at a subpath (via Rancher proxy) instead of the root of a domain (e.g. heimdall.my-rancher.org)\
1. Updated `cmd.sh` (dockerfile entrypoint) to include the `sed` replacement of the aforementioned base paths/urls.
1. Added `.github` to `.gitignore` because it has a lot of workflow and dependabot stuff we don't care about
1. Modified this `README.md` to track these details

## Patch

The patch is in rancher.patch. 

## How to pull in changes from upstream

https://stackoverflow.com/a/30352360

