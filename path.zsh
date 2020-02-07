# Use project specific binaries before global ones
export PATH="node_modules/.bin:$PATH"

# Make sure coreutils are loaded before system commands
# I've disabled this for now because I only use "ls" which is
# referenced in my aliases.zsh file directly.
#export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_SDK="$ANDROID_SDK_ROOT"
export ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk-bundle"
export GPG_TTY=$(tty)

# Use emulator and SDK tools from local SDK folder before global
export PATH="$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$PATH"
