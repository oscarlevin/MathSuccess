#! /bin/bash

# reveal knowls for effect
OPTS="-xinclude -stringparam html.knowl.example no -xinclude -stringparam html.knowl.exercise.inline no"

cd /home/rob/mathbook/local/openstax-convert

MODULES=(m00001 m00002 m00003 m00004)

xsltproc cnxml-pretext.xsl calc3/collection.xml > ptx3/collection.xml

for BASE in ${MODULES[*]}
do
    xsltproc cnxml-pretext.xsl calc3/$BASE/index.cnxml > ptx3/$BASE.xml
done

# cd pdf
# xsltproc ${OPTS} ~/mathbook/mathbook/xsl/mathbook-latex.xsl ../ptx3/collection.xml
# cd ..

echo "LaTeX generation done"

# reveal examples to see them
cd html
xsltproc ${OPTS} ~/mathbook/mathbook/xsl/mathbook-html.xsl ../ptx3/collection.xml
cd ..

# xmllint --format ptx3/collection.xml
# echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# xmllint --format ptx3/m53834.xml
# echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


# Prettyprint
# xmllint --format calc3/m53900/index.cnxml > m53900-nice.xml