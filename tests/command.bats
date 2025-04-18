#!/usr/bin/env bats
# shellcheck disable=SC2059,SC2086,SC2140

setup() {
    load "$BATS_PLUGIN_PATH/load.bash"

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    # make executables in src/ visible to PATH
    PATH="$DIR/../hooks:$PATH"

    source "$DIR/../lib/functions.bash"

    # Uncomment to enable stub debugging
    # export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty
}

@test "GIVEN skip-publish is true THEN do not publish the tag" {
    export BUILDKITE_PLUGIN_UM_TAG_PUBLISHER_PLATFORM="android"
    export BUILDKITE_PLUGIN_UM_TAG_PUBLISHER_TAG_NAME="android-contract"
    export BUILDKITE_PLUGIN_UM_TAG_PUBLISHER_FILE_PATH="android/contract/build.gradle"
    export BUILDKITE_BRANCH="main"

    export BUILDKITE_BUILD_CREATOR="test_user"
    export BUILDKITE_BUILD_CREATOR_EMAIL="test_user@fanduel.com"
    export BUILDKITE_ORGANIZATION_SLUG="fanduel"
    export BUILDKITE_PIPELINE_SLUG="um-android-contract"
    export BUILDKITE_BUILD_NUMBER="123"
    export BUILDKITE_REPO="git@github.com:fanduel/um_repo_name.git"
    export BUILDKITE_BUILD_URL="https://buildkite.com/fanduel/um-android-contract/builds/123"

    run bash -c "echo 'tagging with tag name'"

    stub buildkite-agent \
        "meta-data get 'skip-publish' --default 'true' : echo 'true'"

    run "$PWD/hooks/command"

    assert_success

    unstub buildkite-agent
}

@test "GIVEN skip-publish is false THEN publish the tag" {
    bats_require_minimum_version 1.5.0

    export BUILDKITE_PLUGIN_UM_TAG_PUBLISHER_PLATFORM="android"
    export BUILDKITE_PLUGIN_UM_TAG_PUBLISHER_TAG_NAME="android-contract"
    export BUILDKITE_PLUGIN_UM_TAG_PUBLISHER_FILE_PATH="android/contract/build.gradle"
    export BUILDKITE_BRANCH="main"

    export BUILDKITE_BUILD_CREATOR="test_user"
    export BUILDKITE_BUILD_CREATOR_EMAIL="test_user@fanduel.com"
    export BUILDKITE_ORGANIZATION_SLUG="fanduel"
    export BUILDKITE_PIPELINE_SLUG="um-android-contract"
    export BUILDKITE_BUILD_NUMBER="123"
    export BUILDKITE_REPO="git@github.com:fanduel/um_repo_name.git"
    export BUILDKITE_BUILD_URL="https://buildkite.com/fanduel/um-android-contract/builds/123"

    stub get_platform_version_strings \
        "android android/contract/build.gradle : echo '1.0.0'"

    stub git \
        "config \* \* : echo 'git config'" \
        "config \* \* : echo 'git config'" \
        "fetch --tags : echo 'git fetch'" \
        "tag \* -m \* : echo 'git tag'" \
        "push \* \* : echo 'git push'" \

    stub buildkite-agent \
        "meta-data get 'skip-publish' --default 'true' : echo 'meta-data get skip-publish: false'" \
        "meta-data set 'publish-tag' \* : echo 'meta-data set publish-tag'" \
        "annotate 'Successfully tagged \`android-contract/1.0.0\`' --style 'success' --context 'android-contract-tag-push' : echo 'tag success'"

    run "$PWD/hooks/command"

    assert_success
    assert_output --partial "tag success"

    unstub git
    unstub buildkite-agent
    unstub get_platform_version_strings
}
