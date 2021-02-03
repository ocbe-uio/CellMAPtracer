WIKIFOLDER=WikiSourceCode

all : $(WIKIFOLDER)/BT549_trajectory_analysis.md $(WIKIFOLDER)/RPE_trajectory_analysis.md

$(WIKIFOLDER)/BT549_trajectory_analysis.md : $(WIKIFOLDER)/BT549_trajectory_analysis.Rmd #Data/BT549_trajectory_analysis/*
	@echo -e '\n# Building markdown file ####################################\n'
	R -e 'rmarkdown::render("$<", rmarkdown::md_document(variant="markdown_github", toc=TRUE, toc_depth=1))'
	@echo -e '\n# Replacing image paths #####################################\n'
	sed -i -e 's+!\[\](+![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/master/$(WIKIFOLDER)/+g' $@
	@echo -e '\n# Copying markdown file to clipboard ########################\n'
	cat $@ | xclip -selection clipboard

$(WIKIFOLDER)/RPE_trajectory_analysis.md : $(WIKIFOLDER)/RPE_trajectory_analysis.Rmd #Data/RPE_trajectory_analysis/*
	@echo -e '\n# Building markdown file ####################################\n'
	R -e 'rmarkdown::render("$<", rmarkdown::md_document(variant="gfm", toc=TRUE, toc_depth=1))'
	@echo -e '\n# Replacing image paths #####################################\n'
	sed -i -e 's+!\[\](+![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/master/$(WIKIFOLDER)/+g' $@
	@echo -e '\n# Copying markdown file to clipboard ########################\n'
	cat $@ | xclip -selection clipboard