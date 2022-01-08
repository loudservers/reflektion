# Reflektion

Update image names and tags in a git repo with Lambda.

Inspired by Keith's (klayers) [blog post](https://www.keithrozario.com/2019/09/using-the-bash-custom-runtime-to-update-the-github-repo.html).

We have argoCD configured to watch for updates in a repo. This lambda will update app image IDs in the repo when invoked, such as when the image building pipeline finishes.

## Usage

### Running and testing locally

Copy `example-env.list` to `env.list` and replace the values.
Copy `example-payload.json` to `payload.json` and replace the values.

Run `make start` to build and run the Amazon Linux 2 prepared container. The container will continue to run in the background. In another tab, run `make invoke` to invoke the lambda with the payload.json information.
