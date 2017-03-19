#!/bin/sh -x

# Use passed value or default for location of DITA-OT

case "$#${DITA_DIR:-NOTSET}" in
    0NOTSET)    echo "0NOTSET"
                DITA_OT_DIR="/Users/staylor/Documents/Repos/build-techcomm/deps/DITA-OT1.8/" ;;
    1*)         echo "1"
                DITA_OT_DIR="$1" ;;
    0*)         echo "0"
                DITA_OT_DIR="${DITA_DIR}" ;;
esac

WORKING_DIR=$PWD

# Init Open Toolkit
# cd "${DITA_OT_DIR}"
# . ./startcmd.sh

cd /Users/staylor/Documents/Repos/build-techcomm
. bootstrap.sh

cd "${WORKING_DIR}"
export ANT_HOME="$DITA_DIR"/tools/ant
export ANT_OPTS="-Xmx512m"
export ANT_OPTS="$ANT_OPTS -Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl"
export ANT_OPTS="$ANT_OPTS -Dant.XmlLogger.stylesheet.uri=build_log.xsl"
export ANT_OPTS="$ANT_OPTS -Ddita.dir=$DITA_DIR"
export ANT_OPTS="$ANT_OPTS -Dfop.home=$FOP_HOME"

export ANT_ARGS="-logger org.apache.tools.ant.XmlLogger"

$ANT_HOME/bin/ant -logfile "$WORKING_DIR/logs/test_stemmer.xml" -buildfile buildfile.xml

cd "${WORKING_DIR}"

cp -vf logs/test_stemmer.xml ~/Sites/stemmer_logs/
