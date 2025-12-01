#1/bin/bash

src=../tip-dev
css=css/border.css
tmp=tmp/tmp

mkdir -p tmp html/ex html/ref
cat $src/README.md | sed 's%doc/%html/%g' | sed 's%\.md%.html%g' > tip-doc
pandoc -f markdown -t tip-doc readme -s --embed-resources -c $css -o index.html 
rm tip-doc

for f in $src/doc/*.md $src/doc/ex/*.md $src/doc/ref/*.md ; do
    echo $f
    f2=$(basename ${f%.*})
    cat $f | sed 's%\.md%.html%g' > $f2
    dest=$(echo ${f%.*}.html | sed 's%md/%html/%g')
    pandoc -f markdown -t html $f2 -s --embed-resources -c $css -o $tmp
    cat $tmp | sed 's|<pre><code>|<pre><code>\n|g' \
	| sed 's|</code></pre>|\n </code></pre>|g' > $dest
    rm $f2
done
