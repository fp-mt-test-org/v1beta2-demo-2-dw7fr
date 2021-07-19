#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Purpose of this file is to execute the battenberg install command
# and feed in the values previously configured in the context file.

template_context_file='.cookiecutter.json'
template_context_path="./${template_context_file}"

echo "template_context_file:"
cat "${template_context_path}"
echo "end template_context_file."
echo

# This codeblock answers the prompts issued by battenberg below.
{
    if [[ -d "$HOME/.cookiecutters" ]]; then
        # You've downloaded .../.cookiecutters/template-java-kotlin-library before.
        # Is it okay to delete and re-download it? [yes]:
        echo "1";
        sleep 1;
    fi

    # component_id []:
    jq -r '.component_id' ${template_context_path}
    sleep 1;

    # java_package_name [javakotlinlibtest*****]:
    jq -r '.java_package_name' ${template_context_path}
    sleep 1;

} | battenberg install "${github_base_url}/${template_name}"
