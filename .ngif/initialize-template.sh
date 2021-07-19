#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

if [[ ${CI:-} ]]; then
    git config user.name "CI"
    git config user.email "ci@ci.com"
fi

template_branch_name='initialize-template'

git checkout -b "${template_branch_name}"

template_context_file='.cookiecutter.json'
install_script='battenberg-install-template.sh'
battenberg_output=$(./.ngif/${install_script} 2>&1 || true)

echo
echo "battenberg_output:"
echo "${battenberg_output}"
echo "end battenberg_output"
echo

if [[ ${battenberg_output} =~ Aborted! ]]; then
    echo "Battenberg aborted!"
    exit 1
fi

echo "template_context_file:"
cat "${template_context_file}"
echo "end template_context_file."
echo

# The "|| true" above is to prevent this script from failing
# in the event that initialize-template.sh fails due to errors,
# such as merge conflicts.

echo
echo "Checking for MergeConflictExceptions..."
echo
if [[ "${battenberg_output}" =~ "MergeConflictException" ]]; then
    
    echo "Merge Conflict Detected, attempting to resolve!"

    # Remove all instances of:
    # <<<<<<< HEAD
    # ...
    # =======
    
    # And

    # Remove all instances of:
    # >>>>>>> 0000000000000000000000000000000000000000
    
    cookiecutter_json_updated=$(cat ${template_context_file} | \
        perl -0pe 's/<<<<<<< HEAD[\s\S]+?=======//gms' | \
        perl -0pe 's/>>>>>>> [a-z0-9]{40}//gms')

    echo "${cookiecutter_json_updated}" > "${template_context_file}"
    echo
    cat "${template_context_file}"
    echo
    echo "Conflicts resolved, committing..."
    git add "${template_context_file}"
    git commit -m "fix: Resolved merge conflicts with template."
else
    echo "No merge conflicts detected."
fi

echo
cat "${template_context_file}"
echo
echo "Git Status:"
git status
echo

template_field='_template'
echo "Updating ${template_field} field from:"
echo "UPDATE ME"

echo "Pushing template and current branches to remote..."
git push origin template
echo
 git push --set-upstream origin "${template_branch_name}"
