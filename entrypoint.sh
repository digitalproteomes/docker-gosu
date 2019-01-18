#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-1000}
GROUP_ID=${LOCAL_GROUP_ID:-1000}

usermod -u $USER_ID user
groupmod -g $GROUP_ID userg
usermod -a -G sudo user

## Execute CMD passed by the user when statrting the image
exec /usr/local/bin/gosu user "$@"

