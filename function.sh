#!/bin/sh

export TMP_DIR="/tmp/reflekt"
export GIT_SSH="${TMP_DIR}/.ssh"
export GIT_ID_RSA="${GIT_SSH}/id_rsa"
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=${LAMBDA_TASK_ROOT}/known_hosts -i ${GIT_ID_RSA}" # Automatically points git to use this command

console () {
    echo "$1" 1>&2
}

handler () {
    trap cleanup EXIT

    main "$1"
}

main () {
    EVENT_DATA=$1
    console "$EVENT_DATA"

    mkdir -p "${TMP_DIR}"

    prepare_key

    image_name=$(echo $EVENT_DATA | jq -r .repo_name)
    image_tag=$(echo $EVENT_DATA | jq -r .image_tag)
    app_name=$(echo $EVENT_DATA | jq -r .app)

    file_name="$app_name/base.yaml"

    prepare_git # sets dest_repo_dir
    console "Dir: $dest_repo_dir"

    app_file="$dest_repo_dir/${APPS_DIR}/$file_name"
    console "App: $app_file"
    if [ ! -f "$app_file" ]; then
        console "App file does not exist!"
        exit 1
    fi

    sed -i "s/${IMAGE_TAG_VAR}: \".*\"/${IMAGE_TAG_VAR}: \"$image_tag\"/g" "$app_file"

    commit_change "$app_name"

    RESPONSE="Complete"
    echo $RESPONSE
    cleanup
}

prepare_key () {
    console "Preparing key.."
    echo "$SSH_KEY_PARAMETER" 1>&2
    mkdir -p $GIT_SSH

    aws ssm get-parameter --name "${SSH_KEY_PARAMETER}" --with-decryption --query 'Parameter.Value' --output text > ${GIT_ID_RSA}
    chmod 400 ${GIT_ID_RSA}
}

prepare_git () {
    console "Preparing git.."
    local dest_repo_name=$(echo "$DESTINATION_REPO" | cut -d'/' -f2 | cut -d'.' -f1)

    dest_repo_dir="${TMP_DIR}/$dest_repo_name"

    git clone --single-branch --branch "${BRANCH}" "$DESTINATION_REPO" "$dest_repo_dir"

    echo "[user]
	    email = reflektion@loudservers.com
	    name = reflektion" >> "$dest_repo_dir/.git/config"
}

commit_change () {
    console "Commiting change.."
    local app_name=$1
    cd "$dest_repo_dir"
    make render
    git add -A
    console "$(git status)"
    if [ -n "$(git status --porcelain)" ]; then
        git commit -m "Updating image tag for $app_name"
	    git push origin HEAD
    else
        echo "No changes to make"
    fi
}

cleanup () {
    console "Running cleanup!"
    rm -rf ${TMP_DIR}
}
