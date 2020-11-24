BT549_trajectory_analysis.md : BT549_trajectory_analysis.Rmd
	echo 'Building markdown file'
	R -e 'rmarkdown::render("BT549_trajectory_analysis.Rmd", output_format = "md_document")'
	echo 'Replacing image paths'
	sed -i -e 's+!\[\](+![](https://raw.githubusercontent.com/ocbe-uio/CellMAPtracer/wiki/Wiki/+g' BT549_trajectory_analysis.md
	echo 'Copying markdown file to clipboard'
	cat BT549_trajectory_analysis.md | xclip -selection clipboard