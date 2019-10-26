# Use project specific binaries before global ones
export PATH="node_modules/.bin:$PATH"

# Make sure coreutils are loaded before system commands
# I've disabled this for now because I only use "ls" which is
# referenced in my aliases.zsh file directly.
#export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

export ANDROID_SDK_ROOT="$(brew --prefix)/share/android-sdk"
export ANDROID_NDK_HOME="$(brew --prefix)/share/android-ndk"
