#1/bin/bash

src=$(echo $PWD | sed 's%html%dev%g')
css=$PWD/css/border.css
tmp=$PWD/tmp/tmp

echo "generating directries ..."
mkdir -p tmp en/ex en/ref jp/ref
if [ ! -e en/fig ] ; then
    cp -rp $src/doc/fig en
    ln -s en/fig .
fi
echo "generating index.html"
cat $src/README.md | sed 's%doc/%en/%g' | sed 's%\.md%.html%g' > tip
pandoc -f markdown -t html tip -s --self-contained -c $css -o README.html \
       >& /dev/null

#cat $src/jp/README.md | sed 's%/README%/index%g' | sed 's%\.md%.html%g' > tip
#pandoc -f markdown -t html tip -s --self-contained -c $css -o jp/index.html \
#       >& /dev/null

rm tip

cd en
for f in $src/doc/*.md $src/doc/ex/*.md $src/doc/ref/*.md ; do
    f2=$(basename ${f%.*})
    cat $f | sed 's%\.md%.html%g' | sed 's%\[@\]%[ @ ]%g' > $f2
    dest=$(echo ${f%.*}.html | sed "s%$src/doc/%%g")
    echo "generating en/$dest"
    pandoc -f markdown -t html $f2 -s --self-contained -c $css -o $tmp \
	   >& /dev/null 
    cat $tmp | sed 's|<pre><code>|<pre><code>\n|g' \
	| sed 's|</code></pre>|\n </code></pre>|g' > $dest
    rm $f2
done
cd ..

cd jp
for f in $src/jp/*.md $src/jp/ref/*.md ; do
    f2=$(basename ${f%.*})
    cat $f | sed 's%\.md%.html%g' | sed 's%../doc/%../en/%g' \
	| sed 's%\[@\]%[ @ ]%g' > $f2
    dest=$(echo ${f%.*}.html | sed "s%$src/jp/%%g")
    echo "generating jp/$dest"
    pandoc -f markdown -t html $f2 -s --self-contained -c $css -o $tmp \
	   >& /dev/null 
    cat $tmp | sed 's|<pre><code>|<pre><code>\n|g' \
	| sed 's|</code></pre>|\n </code></pre>|g' > $dest
    rm $f2
done
cd ..

echo "removing temporary directry"
if [ -e fig ] ; then
    rm fig
fi

