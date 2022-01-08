# Reflektion

Update image names and tags in a git repo with Lambda.

Inspired by Keith's (klayers) [blog post](https://www.keithrozario.com/2019/09/using-the-bash-custom-runtime-to-update-the-github-repo.html).

We have argoCD configured to watch for updates in a repo. This lambda will update app image IDs in the repo when invoked, such as when the image building pipeline finishes.

## Details

This lambda utilizes AWS' [custom runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html) containers to use shell. It's a bit simpler than utilizing git libraries for programming languages such as python. There's certainly tradeoffs with both solutions but i'm usually in favor of simple to use commands.

## Usage

### Assumptions

#### Destination repo

The destination repo has a yaml file that has information about the container (or deployment) in the following format:

```
imageName: "private.registry/exampleapp/web"
imageTag: "main-12345678"
environment: "local-prod"
services:
   [...]
```

The environment variable `IMAGE_TAG_VAR` should be filled with your equivalent to perform the replace command (In the example above: `IMAGE_TAG_VAR:imageTag`). Same with `IMAGE_NAME_VAR`.

In our specific usage, it's the values file for our application helm chart where ArgoCD watches for changes.

#### Payload

When invoking the lambda, send the following JSON information at a minimum:

```
{
    "app": "exampleapp",
    "image_repo_name": "loudservers/exampleapp",
    "image_tag": "abcde1234567"
}
```

The lambda will use the information above to infer directories and perform replacements.

#### SSH Key

The lambda also assumes your repository is private and/or pushing changes requires an SSH key. The SSH private key can be stored in AWS SSM Parameter Store. Include the parameter path to the env.list (local) and Lambda (In AWS) by setting the `SSH_KEY_PARAMETER` environment variable and ensure the lambda has proper IAM access to the key.

### Running and testing locally

Copy `example-env.list` to `env.list` and replace the values.
Copy `example-payload.json` to `payload.json` and replace the values.

Run `make start` to build and run the Amazon Linux 2 prepared container. The container will continue to run in the background. In another tab, run `make invoke` to invoke the lambda with the payload.json information.
