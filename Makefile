

readme:
	perl -MPod::Markdown -e 'Pod::Markdown->new->filter(@ARGV)' lib/Throwable/Error/SomeSugar.pm > README.md
