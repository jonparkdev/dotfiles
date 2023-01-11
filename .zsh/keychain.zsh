# for keychain ssh management
if [[ ${MACOS} ]]; then
    eval `/opt/homebrew/bin/keychain --eval --agents ssh --inherit any github_rsa`
    eval `/opt/homebrew/bin/keychain --eval --agents ssh --inherit any homelab`
elif [[ ${LINUX} ]]; then
    eval `/usr/bin/keychain --clear --eval --agents ssh --inherit any github_rsa`
    eval `/usr/bin/keychain --clear --eval --agents ssh --inherit any homelab`
fi

