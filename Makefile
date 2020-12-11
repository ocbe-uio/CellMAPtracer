WIKIFOLDER=WikiSourceCode

all : $(WIKIFOLDER)/BT549_trajectory_analysis.md $(WIKIFOLDER)/RPE_trajectory_analysis.md

$(WIKIFOLDER)/BT549_trajectory_analysis.md : $(WIKIFOLDER)/BT549_trajectory_analysis.Rmd #Data/BT549_trajectory_analysis/*
	echo 'Building markdown file'
	R -e 'rmarkdown::render("$<", rmarkdown::md_document(variant="markdown_github", toc=TRUE, toc_depth=1))'
	echo 'Replacing image paths'
	sed -i -e 's+!\[\](+![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/master/$(WIKIFOLDER)/+g' $@
	echo 'Copying markdown file to clipboard'
	cat $@ | xclip -selection clipboard

$(WIKIFOLDER)/RPE_trajectory_analysis.md : $(WIKIFOLDER)/RPE_trajectory_analysis.Rmd #Data/RPE_trajectory_analysis/*
	echo 'Building markdown file'
	R -e 'rmarkdown::render("$<", rmarkdown::md_document(variant="gfm", toc=TRUE, toc_depth=1))'
	echo 'Replacing image paths'
	sed -i -e 's+!\[\](+![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/master/$(WIKIFOLDER)/+g' $@
	echo 'Copying markdown file to clipboard'
	cat $@ | xclip -selection clipboard