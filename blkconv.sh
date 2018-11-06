#/bin/bash

TMPFOLDER="/tmp/bulkconvert_"$USER"_"$(date +%s);
CURFOLDER=$(pwd)
# ${PWD##*/} -> current folder name without absolut path
# sed -e 's[A-Za-z0-9 ]*//g' -> remove everything but letters, digits and whitespace
# sed -e 's/ /_/g' -> replace all whitespace with underscores
# EXAMPLE: /home/user/1. Introduction to Everything -> 1_Introduction_to_Everything
CURFOLDERNAME=$(echo ${PWD##*/}|sed -e 's/[^A-Za-z0-9 ]*//g'|sed -e 's/ /_/g')


documents=0
folders=0
converted=0

# count documents that will be converted
# will only count .od* files
function count_documents {
	local THING # iterator
	for THING in *
	do
		if [ -d "$THING" ]
		then
			((++folders))
			cd "$THING"
			count_documents
			cd ..
		else
			if [[ $THING == *.odg || $THING == *.odt || $THING == *.ods || $THING == *.odp || $THING == *.odf ]]
			then
				((++documents))
			fi
		fi
	done
}


#converts all .od* documents into pdfs using unoconv
function convert_documents {
	local THING # iterator
	local t=0
	for THING in *
	do
		if [ -d "$THING" ]
		then
			cd "$THING"
			convert_documents
			cd ..
		else
			if [[ $THING == *.odg || $THING == *.odt || $THING == *.ods || $THing == *.odp || $THING == *.odf ]]
			then
				t=$(date +%s)
				loffice --headless --convert-to pdf "$THING" 1>/dev/null
				((++converted))
				echo "Converted $converted of $documents documents ($THING) ($(($(date +%s) - $t))s)"
				rm "$THING"
			fi
		fi
	done
}

# for debugging
if [ -d $TMPFOLDER ]
then
	rm -r $TMPFOLDER
fi

mkdir $TMPFOLDER

echo "Copy stuff into temporary folder."
cp -r ./ $TMPFOLDER

cd $TMPFOLDER

count_documents
echo "Found $documents documents in $folders folders."

convert_documents

if [ $converted -eq $documents ]
then
	echo "All $converted documents converted"
else
	echo "Converted $converted of $documents documents"
fi

echo "Package files into nice and tidy zip-archive."
zip -r "$CURFOLDERNAME" ./* 1>/dev/null
mv "$CURFOLDERNAME.zip" "$CURFOLDER"

echo "Cleanup after you!"
rm -r $TMPFOLDER

echo "All is done!"
