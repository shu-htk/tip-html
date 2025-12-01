#1/bin/bash

src=../tip-dev
css=css/border.css
tmp=tmp/tmp

echo "generating directries ..."
mkdir -p tmp html/ex html/ref
if [ ! -e html/fig ] ; then
    cp -rp $src/doc/fig html
    ln -s html/fig .
    cd ..
    ln -s tip-html/html/fig .
    cd tip-html
fi
echo "generating index.html"
cat $src/README.md | sed 's%doc/%html/%g' | sed 's%\.md%.html%g' > tip
pandoc -f markdown -t html tip -s --self-contained -c $css -o index.html \
       >& /dev/null
rm tip

for f in $src/doc/*.md $src/doc/ex/*.md $src/doc/ref/*.md ; do
    f2=$(basename ${f%.*})
    cat $f | sed 's%\.md%.html%g' | sed 's%\[@\]%[ @ ]%g' > $f2
    dest=$(echo ${f%.*}.html | sed "s%$src/doc%html%g")
    echo "generating $dest"
#    echo $f $f2 $dest
    pandoc -f markdown -t html $f2 -s --self-contained -c $css -o $tmp \
	   >& /dev/null 
    cat $tmp | sed 's|<pre><code>|<pre><code>\n|g' \
	| sed 's|</code></pre>|\n </code></pre>|g' > $dest
    rm $f2
done

echo "removing temporary directries ..."
for d in fig ../fig ; do
    if [ -e $d ] ; then
	rm $d
    fi
done

