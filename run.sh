# Download list of recently changed articles
#wget -O /tmp/changes.html "http://wikitravel.org/wiki/en/index.php?title=Special:RecentChanges&limit=500"
grep "mw-line-" /tmp/changes.html | grep -v "User creation log" | grep -v "title=\"User:" | sed -e "s/.*title=\"//" | grep -v "^User talk:" | sed -e "s/\".*//" | sort -u | shuf > /tmp/changes.txt

# Manually check each article
cat /tmp/changes.txt | while read ARTICLE
do
	# Get WT wikicode
	wget -qO /tmp/wt.html "http://wikitravel.org/wiki/en/index.php?title=$ARTICLE&action=edit"
	cat /tmp/wt.html | awk 'BEGIN{RS="</textarea>"} NR==1 {print;exit}' | awk '/<textarea/{close("part_"f);f++}{print $0 > "part_"f}'
	rm part_
	grep -v "<textarea" part_1 | sed -e "s/&lt;/</" > /tmp/wt.wikicode
	rm part_1

	# Get WV wikicode
	wget -qO /tmp/wv.html "http://en.wikivoyage.org/w/index.php?title=$ARTICLE&action=edit"
	cat /tmp/wv.html | awk 'BEGIN{RS="</textarea>"} NR==1 {print;exit}' | awk '/<textarea/{close("part_"f);f++}{print $0 > "part_"f}'
	rm part_
	grep -v "<textarea" part_1 | sed -e "s/&lt;/</" > /tmp/wv.wikicode
	rm part_1
	
	echo ""
	echo "In the window that opens, find the interesting contributions in the left pane, and click on the arrows to merge them to the right."
	echo "When done, on the right pane press CTRL-A and CTRL-C, then open http://en.wikivoyage.org/w/index.php?title=$ARTICLE&action=edit (right-click in terminal), paste, show changes, and save."
	echo "Close meld to continue with another file."
	meld /tmp/wt.wikicode /tmp/wv.wikicode
done
