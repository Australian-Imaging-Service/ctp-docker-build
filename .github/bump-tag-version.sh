#!/bin/bash
DELTA=30

THRESHOLD=$(date -d "$DELTA days ago" +%Y-%m-%d)
TAG_DATE=$(git tag --format='%(creatordate:short)  %(refname:strip=2)' --sort=-creatordate | awk '{print $1; exit}')
if [[ $TAG_DATE < $THRESHOLD ]]; then
	TAG_LATEST=$(git describe --tags --abbrev=0)
	TAG_NEW=$(echo $TAG_LATEST | awk -F. '{$NF = $NF +1;} 1' OFS=.)
	git tag -a $NEW_TAG -m "Bump version to $NEW_TAG"
	git push origin $NEW_TAG
fi
