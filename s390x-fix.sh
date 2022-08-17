#!/bin/sh

set -xe

YARN=4.2.2

apk --no-cache update
apk --no-cache add jq moreutils g++ gcc libgcc libstdc++ linux-headers make python3 git

npm install -g --force yarn

mkdir -p /root/yarn-setup
(cd /root/yarn-setup && yarn set version $YARN)

rm .yarn/releases/yarn*.cjs
cp /root/yarn-setup/.yarn/releases/*.cjs .yarn/releases/
sed -i "s/\(^yarnPath:.*\/yarn-\).*\.cjs/\1$YARN.cjs/" .yarnrc.yml

sed -i "/@yarnpkg\/plugin-typescript/d; /@yarnpkg\/plugin-interactive-tools/d" .yarnrc.yml

for f in `find . -type f -name "package.json" -exec grep -l "swc/" {} +`; do
	jq '.devDependencies|=with_entries(select(.key|test("^@swc/.*")|not))' < $f | sponge $f
done

yarn set version $YARN
