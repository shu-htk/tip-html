#1/bin/bash

opt=${1:-null}
src=$(echo $PWD | sed 's%html%dev%g')
css=$PWD/css/border.css
tmp=$PWD/tmp/tmp

echo "generating directries ..."
mkdir -p tmp en/ex en/ref jp/ref
ln -s en/fig .
if [ ! -e en/fig ] ; then
    cp -rp $src/doc/fig en
fi
if [ $src/README.md -nt README.html ] || [ $opt == force ] ;then
    echo "update index.html"
    cat $src/README.md | sed 's%doc/%en/%g' | sed 's%\.md%.html%g' > tip
    pandoc -f markdown -t html tip -s --self-contained -c $css -o README.html \
	   >& /dev/null
    rm tip
fi

cd en
for f in $src/doc/*.md $src/doc/ex/*.md $src/doc/ref/*.md ; do
    dest=$(echo ${f%.*}.html | sed "s%$src/doc/%%g")
    if [ $f -nt $dest ] || [ $opt == force ] ; then
	f2=$(basename ${f%.*})
	cat $f | sed 's%\.md%.html%g' | sed 's%\[@\]%[ @ ]%g' > $f2
	echo "update en/$dest"
	pandoc -f markdown -t html $f2 -s --self-contained -c $css -o $tmp \
	       >& /dev/null 
	cat $tmp | sed 's|<pre><code>|<pre><code>\n|g' \
	    | sed 's|</code></pre>|\n </code></pre>|g' > $dest
	rm $f2
    fi
done
cd ..

cd jp
for f in $src/jp/*.md $src/jp/ref/*.md ; do
    dest=$(echo ${f%.*}.html | sed "s%$src/jp/%%g")
    if [ $f -nt $dest ] || [ $opt == force ] ; then
	f2=$(basename ${f%.*})
	cat $f | sed 's%\.md%.html%g' | sed 's%../doc/%../en/%g' \
	    | sed 's%\[@\]%[ @ ]%g' > $f2
	echo "update jp/$dest"
	pandoc -f markdown -t html $f2 -s --self-contained -c $css -o $tmp \
	       >& /dev/null 
	cat $tmp | sed 's|<pre><code>|<pre><code>\n|g' \
	    | sed 's|</code></pre>|\n </code></pre>|g' > $dest
	rm $f2
    fi
done
cd ..

if [ -e fig ] ; then
    echo "removing temporary directry"
    rm fig
fi

